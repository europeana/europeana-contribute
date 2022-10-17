# frozen_string_literal: true

if Rails.cache.is_a?(ActiveSupport::Cache::RedisStore)
  redis_options = Rails.cache.data.instance_values['options']
  redis_options[:namespace] = 'sidekiq'

  Sidekiq.configure_server do |config|
    config.redis = redis_options
  end

  Sidekiq.configure_client do |config|
    config.redis = redis_options
  end
end
