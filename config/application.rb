# frozen_string_literal: true

require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
# require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'action_cable/engine'
require 'sprockets/railtie'
# require 'rails/test_unit/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Europeana
  module Stories
    class Application < Rails::Application
      # Initialize configuration defaults for originally generated Rails version.
      config.load_defaults 5.1

      # Settings in config/environments/* take precedence over those specified here.
      # Application configuration should go into files in config/initializers
      # -- all .rb files in that directory are automatically loaded.

      # Setup redis as the cachestore if settings for it are available.
      # This is required for sidekiq, which uses redis to queue jobs.
      config.cache_store = begin
        redis_config = Rails.application.config_for(:redis).symbolize_keys
        fail RuntimeError unless redis_config.present?
        [:redis_store, redis_config[:url]]
      rescue RuntimeError
        :null_store
      end

      config.middleware.use ::I18n::JS::Middleware

      config.log_level = :debug

      # Don't generate system test files.
      config.generators.system_tests = nil
    end
  end
end
