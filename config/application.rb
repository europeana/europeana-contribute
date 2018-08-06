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
# require 'action_cable/engine'
require 'jquery-rails'
require 'jquery-ui-rails'
require 'sprockets/railtie'
# require 'rails/test_unit/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require 'rdf/rdfa'

module Europeana
  module Contribute
    class Application < Rails::Application
      # Initialize configuration defaults for originally generated Rails version.
      config.load_defaults 5.1

      # Settings in config/environments/* take precedence over those specified here.
      # Application configuration should go into files in config/initializers
      # -- all .rb files in that directory are automatically loaded.

      # Setup redis as the cache_store.
      # This is required for sidekiq, which uses redis to queue jobs.
      config.cache_store = begin
        redis_config = Rails.application.config_for(:redis).deep_symbolize_keys
        opts = {}
        if redis_config[:url].start_with?('rediss://')
          opts[:ssl] = :true
          opts[:scheme] = 'rediss'
        end
        if redis_config[:ssl_params]
          opts[:ssl_params] = {
            ca_file: redis_config[:ssl_params][:ca_file]
          }
        end
        fail 'Redis configuration is required.' unless redis_config.present?
        [:redis_store, redis_config[:url], opts]
      end
      config.active_job.queue_adapter = :sidekiq

      config.log_level = :debug

      # Don't generate system test files.
      config.generators.system_tests = nil

      if ENV['ENABLE_FORCE_SSL'] == '1'
        config.force_ssl = true
        config.ssl_options = { redirect: { exclude: ->(request) { request.path =~ %r{\A/oai(/|\z)} } } }
      end
    end
  end
end
