# frozen_string_literal: true

# NOTE: params[:uuid] is expected to be the UUID of the CHO, not the contribution
#       or aggregation because the CHO is the "core" object and others
#       supplementary, and its UUID will be published and need to be permanent.
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
