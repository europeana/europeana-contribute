# frozen_string_literal: true

Rails.application.config.x.europeana = OpenStruct.new(
  entities: OpenStruct.new(
    api_url: ENV['EUROPEANA_ENTITIES_API_URL'] || 'https://www.europeana.eu/api'
  ).freeze
).freeze
