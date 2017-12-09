# frozen_string_literal: true

class OAIController < ApplicationController
  def index
    provider = Europeana::Stories::OAI::Provider.new
    options = params.permit(*oai_pmh_request_arguments).to_hash
    # TODO: this fails if no ORE::Aggregation documents exist
    response =  provider.process_request(options)
    render xml: response
  end

  protected

  def oai_pmh_request_arguments
    %i(verb identifier metadataPrefix from until set resumptionToken)
  end
end
