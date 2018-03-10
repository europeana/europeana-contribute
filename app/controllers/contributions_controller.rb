# frozen_string_literal: true

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

    @contributions = chos.map { |cho| cho.edm_aggregatedCHO_for.contribution }
  end

  # NOTE: params[:uuid] is expected to be the UUID of the CHO, not the contribution
  #       or aggregation because the CHO is the "core" object and others
  #       supplementary, and its UUID will be published and need to be permanent.
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

  def wipe
    @contribution = Contribution.find(params[:id])
    authorize! :wipe!, @contribution
    @contribution.wipe!
    redirect_to action: :index
  rescue
    redirect_to action: :index, flash: "Unable to delete #{@contribution.dc_title}."
  end

  protected

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
