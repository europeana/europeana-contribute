# frozen_string_literal: true

redis_url = nil

if Rails.cache.is_a?(ActiveSupport::Cache::RedisStore)
  redis_url = Rails.cache.data.connection[:id]
end

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url, namespace: 'sidekiq' }.merge!(Rails.cache.options.deep_symbolize_keys)
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url, namespace: 'sidekiq' }.merge!(Rails.cache.options.deep_symbolize_keys)
end