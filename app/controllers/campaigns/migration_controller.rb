# frozen_string_literal: true

module Campaigns
  class MigrationController < ApplicationController
    include Recaptchable
    include Contributable

    private

    def campaign
      @campaign ||= Campaign.find_by(dc_identifier: 'migration')
    end

    def campaign_redirect_url
      Rails.application.config.x.campaigns.migration.submission_redirect
    end
  end
end
