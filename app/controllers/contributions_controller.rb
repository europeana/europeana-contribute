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
    aggregation = cho.edm_aggregatedCHO_for
    authorize! :show, aggregation.contribution
    respond_to do |format|
      format.jsonld { render json: aggregation.to_jsonld }
      format.nt { render plain: aggregation.to_ntriples }
      format.rdf { render xml: aggregation.to_rdfxml }
      format.ttl { render plain: aggregation.to_turtle }
    end
  end

  def edit
    cho = EDM::ProvidedCHO.find_by(uuid: params[:uuid])
    contribution = cho.edm_aggregatedCHO_for.contribution
    authorize! :edit, contribution
    redirect_to send(:"edit_#{contribution.campaign.dc_identifier}_path", cho)
  end

  protected

  # This is very ugly but otherwise we see a huge proliferation of MongoDB
  # queries for very little data needed on the index view.
  #
  # TODO: consider duplicating required data onto the contribution documents
  #   or indexing in a search engine
  def assemble_index_contributions(chos)
    chos = chos.pluck(:id, :uuid, :dc_identifier, :dc_contributor_agent_id)
    cho_ids = chos.map(&:first)
    contributor_ids = chos.map(&:last)
    contributors = EDM::Agent.where(id: { '$in': contributor_ids }).pluck(:id, :foaf_name)
    aggs = ORE::Aggregation.where(edm_aggregatedCHO_id: { '$in': cho_ids }).pluck(:id, :edm_aggregatedCHO_id)
    agg_ids = aggs.map(&:first)
    cons = Contribution.where(ore_aggregation_id: { '$in': agg_ids }).pluck(:id, :ore_aggregation_id, :aasm_state, :created_at)

    hv_ids = EDM::WebResource.where('edm_hasView_for_id': { '$in': agg_ids }).pluck(:edm_hasView_for_id).flatten
    isb_ids = EDM::WebResource.where('edm_isShownBy_for_id': { '$in': agg_ids }).pluck(:edm_isShownBy_for_id).flatten

    cons.each_with_object([]) do |con, memo|
      agg = aggs.detect { |a| a[0] == con[1] }
      cho = chos.detect { |c| c[0] == agg[1] }
      contributor = contributors.detect { |c| c[0] == cho[3] }
      memo.push({
        uuid: cho[1],
        contributor: contributor[1] || [],
        identifier: cho[2] || [],
        date: con[3],
        status: con[2],
        media: hv_ids.include?(agg[0]) || isb_ids.include?(agg[0])
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
end
