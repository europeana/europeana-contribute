# frozen_string_literal: true

# App-specific configuration settings, read from environment variables.
Rails.application.configure do
  # Base URL of this application, used for dereferenceable URIs in RDF output.
  # No trailing slash.
  # @example 'http://www.example.org'
  config.x.base_url = ENV['APP_BASE_URL']

  # Default edm:dataProvider for ore:aggregations
  # @example 'My Data Provider'
  config.x.edm.data_provider = ENV['APP_DEFAULT_EDM_DATA_PROVIDER']

  # Default edm:provider for ore:aggregations
  # @example 'My Provider'
  config.x.edm.provider = ENV['APP_DEFAULT_EDM_PROVIDER']
end
