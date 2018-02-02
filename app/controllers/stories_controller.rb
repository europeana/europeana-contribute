# frozen_string_literal: true

class StoriesController < ApplicationController
  # TODO: filter stories by status, once implemented
  # TODO: DRY this up
  # TODO: order the stories?
  def index
    authorize! :index, ORE::Aggregation

    if params.key?(:event_id)
      @selected_event = EDM::Event.find(params[:event_id])
      authorize! :read, @selected_event
    end

    if current_user_ability.can?(:manage, ORE::Aggregation)
      # show all stories and events
      @events = EDM::Event.where({})
      @stories = ORE::Aggregation.where(index_query)
    elsif current_user.events.blank?
      # show no stories or events
      @stories = []
      @events = []
    else
      # show user-associated events and their stories
      @events = current_user.events
      @stories = ORE::Aggregation.where(current_user_events_query.merge(index_query))
    end
  end

  protected

  def current_user_ability
    Ability.new(current_user)
  end

  def current_user_events_query
    { 'edm_aggregatedCHO.edm_wasPresentAt_id': { '$in': current_user.event_ids } }
  end

  def index_query
    {}.tap do |query|
      if @selected_event
        query['edm_aggregatedCHO.edm_wasPresentAt_id'] ||= {}
        query['edm_aggregatedCHO.edm_wasPresentAt_id']['$eq'] = @selected_event.id
      end
    end
  end
end
