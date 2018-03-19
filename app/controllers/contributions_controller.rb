# frozen_string_literal: true

# NOTE: params[:uuid] is expected to be the UUID of the CHO, not the contribution
#       or aggregation because the CHO is the "core" object and others
#       supplementary, and its UUID will be published and need to be permanent.
class ContributionsController < ApplicationController
  # TODO: filter contributions by status, once implemented
  # TODO: DRY this up
  # TODO: order the contributions by default
  def index
    authorize! :index, Contribution

    if params.key?(:event_id)
      @selected_event = EDM::Event.find(params[:event_id])
      authorize! :read, @selected_event
    end

    if current_user_can?(:manage, Contribution)
      # show all contributions and events
      @events = EDM::Event.where({})
      @deletion_enabled = true
      chos = EDM::ProvidedCHO.where(index_query)
    elsif current_user.events.blank?
      # show no contributions or events
      @events = []
      chos = []
    else
      # show user-associated events and their contributions
      @events = current_user.events
      chos = EDM::ProvidedCHO.where(current_user_events_query.merge(index_query))
    end

    @contributions = assemble_index_contributions(chos)
  end

  def show
    cho = EDM::ProvidedCHO.find_by(uuid: params[:uuid])
    contribution = cho.edm_aggregatedCHO_for.contribution
    authorize! :show, contribution
    respond_to do |format|
      format.jsonld { render json: contribution.to_jsonld }
      format.nt { render plain: contribution.to_ntriples }
      format.rdf { render xml: contribution.to_rdfxml }
      format.ttl { render plain: contribution.to_turtle }
    end
  rescue Mongoid::Errors::DocumentNotFound
    Contribution.deleted.find_by(oai_pmh_record_id: params[:uuid])
    render_http_status(410)
  end

  def edit
    contribution = contribution_from_params
    authorize! :edit, contribution
    redirect_to send(:"edit_#{contribution.campaign.dc_identifier}_path", params[:uuid])
  end

  def delete
    @contribution = contribution_from_params
    authorize! :wipe, @contribution
  end

  def destroy
    contribution = contribution_from_params
    authorize! :wipe, contribution
    begin
      if contribution.ever_published?
        contribution.wipe!
        flash[:notice] = I18n.t('contribute.contributions.notices.wiped', name: contribution.display_title)
      else
        contribution.destroy!
        flash[:notice] = I18n.t('contribute.contributions.notices.deleted', name: contribution.display_title)
      end
    rescue
      flash[:notice] = I18n.t('contribute.contributions.notices.delete_error', name: contribution.display_title)
    end
    redirect_to action: :index
  end

  protected

  # Local structs to support +#assemble_index_contributions+
  module Index
    Contribution = Struct.new(:id, :ore_aggregation_id, :aasm_state, :created_at)
    module EDM
      Agent = Struct.new(:id, :foaf_name)
      ProvidedCHO = Struct.new(:id, :uuid, :dc_identifier, :dc_contributor_agent_id)
      WebResource = Struct.new(:edm_isShownBy_for_id, :edm_hasView_for_id)
    end
    module ORE
      Aggregation = Struct.new(:id, :edm_aggregatedCHO_id)
    end
  end

  # This is very ugly but otherwise we see a huge proliferation of MongoDB
  # queries for very little data needed on the index view.
  #
  # TODO: consider duplicating required data onto the contribution documents
  #   or indexing in a search engine
  def assemble_index_contributions(chos)
    provided_chos = chos.pluck(*Index::EDM::ProvidedCHO.members).map { |values| Index::EDM::ProvidedCHO.new(*values) }
    contributors = EDM::Agent.where(id: { '$in': provided_chos.map(&:dc_contributor_agent_id) }).
                              pluck(*Index::EDM::Agent.members).map { |values| Index::EDM::Agent.new(*values) }
    aggregations = ORE::Aggregation.where(edm_aggregatedCHO_id: { '$in': chos.map(&:id) }).
                                    pluck(*Index::ORE::Aggregation.members).map { |values| Index::ORE::Aggregation.new(*values) }
    aggregation_ids = aggregations.map(&:id)
    contributions = Contribution.where(ore_aggregation_id: { '$in': aggregation_ids }).
                                 pluck(*Index::Contribution.members).map { |values| Index::Contribution.new(*values) }

    web_resources = (
                      EDM::WebResource.where('edm_hasView_for_id': { '$in': aggregation_ids }, 'media': { '$exists': true, '$ne': nil })
                        .pluck(*Index::EDM::WebResource.members) +
                      EDM::WebResource.where('edm_isShownBy_for_id': { '$in': aggregation_ids }, 'media': { '$exists': true, '$ne': nil })
                        .pluck(*Index::EDM::WebResource.members)
                    ).map { |values| Index::EDM::WebResource.new(*values) }
    media_aggregation_ids = web_resources.map(&:values).flatten.compact

    contributions.each_with_object([]) do |contribution, memo|
      aggregation = aggregations.detect { |aggregation| aggregation.id == contribution.ore_aggregation_id }
      cho = provided_chos.detect { |cho| cho.id == aggregation.edm_aggregatedCHO_id }
      contributor = contributors.detect { |contributor| contributor.id == cho.dc_contributor_agent_id }
      memo.push({
        uuid: cho.uuid,
        contributor: contributor&.foaf_name || [],
        identifier: cho.dc_identifier || [],
        date: contribution.created_at,
        status: contribution.aasm_state,
        media: media_aggregation_ids.include?(aggregation.id),
        deletable: Contribution.aasm.state_machine.events[:wipe].transitions_from_state?(contribution.aasm_state.to_sym)
      })
    end
  end

  def current_user_events_query
    { 'edm_wasPresentAt_id': { '$in': current_user.event_ids } }
  end

  def index_query
    {}.tap do |query|
      if @selected_event
        query['edm_wasPresentAt_id'] ||= {}
        query['edm_wasPresentAt_id']['$eq'] = @selected_event.id
      end
    end
  end

  def contribution_from_params
    cho = EDM::ProvidedCHO.find_by(uuid: params[:uuid])
    cho.edm_aggregatedCHO_for.contribution
  end
end
