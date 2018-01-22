# frozen_string_literal: true

# Helper module for google reCAPTCHA elements used by the styleguide
# see also the reCAPTCHA gem: https://github.com/ambethia/recaptcha
module RecaptchaHelper
  def recaptcha_form_attributes
    if !current_user && Recaptcha&.configuration&.site_key
      { 'recaptcha-site-key': Recaptcha.configuration.site_key }
    else
      {}
    end
  end
end
