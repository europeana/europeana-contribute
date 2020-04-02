# frozen_string_literal: true

module Campaigns
  class SportController < ApplicationController
    include Recaptchable
    include Contributable

    private

    def campaign
      @campaign ||= Campaign.find_by(dc_identifier: 'sport')
    end

    def campaign_redirect_url
      Rails.application.config.x.campaigns.sport.submission_redirect
    end
  end
end
