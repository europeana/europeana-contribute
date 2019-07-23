# frozen_string_literal: true

module Campaigns
  class EuropeAtWorkController < ApplicationController
    include Recaptchable
    include Contributable

    private

    def campaign
      @campaign ||= Campaign.find_by(dc_identifier: 'europe-at-work')
    end

    def campaign_redirect_url
      Rails.application.config.x.campaigns.europe_at_work.submission_redirect
    end
  end
end
