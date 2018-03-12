# frozen_string_literal: true

class OAIController < ApplicationController
  def index
    provider = Europeana::Contribute::OAI::Provider::Base.new
    options = params.permit(*oai_pmh_request_arguments).to_hash
    response =  provider.process_request(options)
    render xml: response
  end

  protected

  def oai_pmh_request_arguments
    %i(verb identifier metadataPrefix from until set resumptionToken)
  end
end
