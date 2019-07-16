# frozen_string_literal: true

Rails.application.config.x.campaigns = OpenStruct.new(
  migration: OpenStruct.new(
    submission_redirect: ENV['CAMPAIGNS_MIGRATION_SUBMISSION_REDIRECT']
  ).freeze,
  europe_at_work: OpenStruct.new(
    submission_redirect: ENV['CAMPAIGNS_EUROPE_AT_WORK_SUBMISSION_REDIRECT']
  ).freeze
).freeze

Rails.application.config.x.europeana = OpenStruct.new(
  entities: OpenStruct.new(
    api_url: ENV['EUROPEANA_ENTITIES_API_URL'] || 'https://www.europeana.eu/api'
  ).freeze
).freeze

Rails.application.config.x.google = OpenStruct.new(
  analytics_key: ENV['GOOGLE_ANALYTICS_KEY']
).freeze
