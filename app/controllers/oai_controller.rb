# frozen_string_literal: true

class OAIController < ApplicationController
  def index
    options = params.except(:controller, :action)
    provider = Europeana::Stories::OAI::Provider.new
    # TODO: this fails if no ORE::Aggregation documents exist
    response =  provider.process_request(options)
    render xml: response
  end
end
