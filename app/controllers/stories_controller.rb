# frozen_string_literal: true

class StoriesController < ApplicationController
  # TODO: filter stories by status, once implemented
  def index
    authorize! :index, ORE::Aggregation

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
      @stories = ORE::Aggregation.where({ 'edm_aggregatedCHO.edm_wasPresentAt_id': { '$in': current_user.event_ids } }.merge(index_query))
    end
  end

  protected

  def current_user_ability
    Ability.new(current_user)
  end

  def index_query
    {}.tap do |query|
      if params.key?(:event_id)
        query['edm_aggregatedCHO.edm_wasPresentAt_id'] ||= {}
        query['edm_aggregatedCHO.edm_wasPresentAt_id']['$eq'] = BSON::ObjectId.from_string(params[:event_id])
      end
    end
  end
end
