# frozen_string_literal: true

class StoriesController < ApplicationController
  # TODO: filter stories by status, once implemented
  # TODO: filter stories by EDM::Event from params
  # TODO: filter events by authorisation
  def index
    authorize! :index, ORE::Aggregation
    @stories = ORE::Aggregation.all
    @events = EDM::Event.all
  end
end
