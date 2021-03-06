# frozen_string_literal: true

# NOTE: params[:uuid] is expected to be the UUID of the CHO, not the contribution
#       or aggregation because the CHO is the "core" object and others
#       supplementary, and its UUID will be published and need to be permanent.
class ContributionsController < ApplicationController
  def index
    authorize! :index, Contribution

    if params.key?(:event_id)
      if params[:event_id] == 'none'
        @selected_event = 'none'
      else
        @selected_event = EDM::Event.find(params[:event_id])
        authorize! :read, @selected_event
      end
    end

    if params.key?(:campaign_id)
      @selected_campaign = Campaign.find(params[:campaign_id])
    end

    index_content_for_current_user do |events, chos|
      @events = events
      @contributions = assemble_index_contributions(chos)
    end

    @campaigns = Campaign.all.order_by(dc_identifier: 1)

    @deletion_enabled = true if current_user_can?(:manage, Contribution)
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
    redirect_to send(:"edit_#{contribution.campaign.to_param}_path", params[:uuid])
  end

  def delete
    @contribution = contribution_from_params
    authorize! :wipe, @contribution
  end

  def destroy
    contribution = contribution_from_params
    authorize! :wipe, contribution
    begin
      contribution.ever_published? ? contribution.wipe! : contribution.destroy!
      flash[:notice] = I18n.t('contribute.contributions.notices.deleted', name: contribution.display_title)
    rescue StandardError
      flash[:notice] = I18n.t('contribute.contributions.notices.delete_error', name: contribution.display_title)
    end
    redirect_to action: :index
  end

  def select_thumbnail
    @contribution = contribution_from_params
    authorize! :edit, @contribution
  end

  def set_thumbnail
    @contribution = contribution_from_params
    authorize! :edit, @contribution

    new_edm_isShownBy_id = params.dig(:contribution, :ore_aggregation_attributes, :edm_isShownBy)
    old_edm_isShownBy_id = @contribution.ore_aggregation.edm_isShownBy.id.to_s

    begin
      unless new_edm_isShownBy_id == old_edm_isShownBy_id
        new_edm_isShownBy = @contribution.ore_aggregation.edm_hasViews.detect { |wr| wr.id.to_s == new_edm_isShownBy_id }
        new_edm_isShownBy.edm_isShownBy_for_id = @contribution.ore_aggregation.id
        new_edm_isShownBy.edm_hasView_for_id = nil

        old_edm_isShownBy = @contribution.ore_aggregation.edm_isShownBy
        old_edm_isShownBy.edm_hasView_for_id = @contribution.ore_aggregation.id
        old_edm_isShownBy.edm_isShownBy_for_id = nil

        @contribution.save
        flash[:notice] = I18n.t('contribute.contributions.notices.thumbnail_updated')
      end
      redirect_to action: :index
    rescue StandardError
      flash[:notice] = I18n.t('contribute.contributions.notices.thumbnail_update_error')
      render action: :select_thumbnail, status: 400
    end
  end

  protected

  # Events and CHOs to display to the current user on the index action
  #
  # @yieldparam events [Array<EDM::Event>] events to display
  # @yieldparam chos [Array<EDM::ProvidedCHO>] CHOs to display
  def index_content_for_current_user
    if current_user_can?(:manage, Contribution)
      # show all contributions and events
      yield EDM::Event.all, EDM::ProvidedCHO.where(chos_index_query)
    elsif current_user.events.blank?
      # show no contributions or events
      yield [], []
    else
      # show user-associated events and their contributions
      yield current_user.events, EDM::ProvidedCHO.where(chos_index_query)
    end
  end

  # Local structs to support +#assemble_index_contributions+
  module Index
    Contribution = Struct.new(:id, :ore_aggregation_id, :aasm_state, :created_at)
    module EDM
      Agent = Struct.new(:id, :skos_prefLabel)
      ProvidedCHO = Struct.new(:id, :uuid, :dc_identifier, :dc_title, :dc_contributor_agent_id)
    end
    module ORE
      Aggregation = Struct.new(:id, :edm_aggregatedCHO_id, :edm_isShownBy_id, :edm_hasView_ids)
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
    contributions = Contribution.where(contributions_index_query(aggregation_ids)).
                    pluck(*Index::Contribution.members).map { |values| Index::Contribution.new(*values) }

    media_aggregation_ids = (
      EDM::WebResource.where('edm_isShownBy_for_id': { '$in': aggregation_ids }, 'media': { '$exists': true, '$ne': nil }).
        pluck(:edm_isShownBy_for_id) +
      EDM::WebResource.where('edm_hasView_for_id': { '$in': aggregation_ids }, 'media': { '$exists': true, '$ne': nil }).
        pluck(:edm_hasView_for_id)
    ).flatten.compact

    aggregations_with_isShownBy_ids = EDM::WebResource.where('edm_isShownBy_for_id': { '$in': aggregation_ids }).
                                      pluck(:edm_isShownBy_for_id)
    aggregations_with_hasView_ids = EDM::WebResource.where('edm_hasView_for_id': { '$in': aggregation_ids }).
                                    pluck(:edm_hasView_for_id)
    thumbnailable_aggregation_ids = aggregations_with_isShownBy_ids & aggregations_with_hasView_ids

    contributions.each_with_object([]) do |contribution, memo|
      ore_aggregation = aggregations.detect { |aggregation| aggregation.id == contribution.ore_aggregation_id }
      provided_cho = provided_chos.detect { |cho| cho.id == ore_aggregation.edm_aggregatedCHO_id }
      cho_contributor = contributors.detect { |contributor| contributor.id == provided_cho.dc_contributor_agent_id }
      memo.push(
        uuid: provided_cho.uuid,
        contributor: cho_contributor&.skos_prefLabel || '',
        title: provided_cho.dc_title || [],
        identifier: provided_cho.dc_identifier || [],
        date: contribution.created_at,
        status: contribution.aasm_state,
        media: media_aggregation_ids.include?(ore_aggregation.id),
        thumbnailable?: thumbnailable_aggregation_ids.include?(ore_aggregation.id),
        removable?: %w(draft).include?(contribution.aasm_state)
      )
    end
  end

  def contributions_index_query(aggregation_ids)
    { ore_aggregation_id: { '$in': aggregation_ids } }.tap do |query|
      if @selected_campaign.present?
        query['campaign_id'] = { '$eq' => @selected_campaign }
      end
    end
  end

  def chos_index_query
    { 'edm_wasPresentAt_id' => {} }.tap do |query|
      if @selected_event.present?
        query['edm_wasPresentAt_id']['$eq'] = (@selected_event == 'none' ? nil : @selected_event.id)
      end

      unless current_user_can?(:manage, Contribution)
        query['edm_wasPresentAt_id']['$in'] = current_user.event_ids
      end

      query.delete('edm_wasPresentAt_id') if query['edm_wasPresentAt_id'].blank?
    end
  end

  def contribution_from_params
    cho = EDM::ProvidedCHO.find_by(uuid: params[:uuid])
    cho.edm_aggregatedCHO_for.contribution
  end
end
