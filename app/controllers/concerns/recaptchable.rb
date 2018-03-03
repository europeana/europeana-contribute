# frozen_string_literal: true

module Recaptchable
  extend ActiveSupport::Concern

  private

  def validate_humanity
    return true unless recaptcha_configured?
    current_user.nil? ? verify_recaptcha(model: @contribution) : true
  end

  def recaptcha_configured?
    [Recaptcha.configuration.site_key, Recaptcha.configuration.secret_key].all?(&:present?)
  end
end
