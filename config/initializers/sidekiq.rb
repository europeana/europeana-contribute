# frozen_string_literal: true

redis_url = nil

if Rails.application.config.cache_store[0] == :redis_store && Rails.application.config.cache_store[1]
  redis_url = Rails.application.config.cache_store[1]
end

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url, namespace: 'sidekiq' }
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url, namespace: 'sidekiq' }
end