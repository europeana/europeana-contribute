# frozen_string_literal: true

class StoriesController < ApplicationController
  # TODO: filter stories by status, once implemented
  # TODO: filter stories by EDM::Event from params
  # TODO: filter events by authorisation
  def index
    authorize! :index, ORE::Aggregation
    @stories = ORE::Aggregation.where(index_query)
    @events = EDM::Event.where({})
  end

  protected

  def index_query
    {}.tap do |query|
      if params.key?(:event_id)
        query['edm_aggregatedCHO.edm_wasPresentAt_id'] = BSON::ObjectId.from_string(params[:event_id])
      end
    end
  end
end
