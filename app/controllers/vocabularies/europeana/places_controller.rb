# frozen_string_literal: true

module Vocabularies
  module Europeana
    class PlacesController < VocabulariesController
      vocabulary_index url: Rails.application.config.x.europeana.entities.api_url + '/entities/suggest',
                       params: {
                         wskey: Rails.application.secrets.europeana_entities_api_key,
                         type: 'place'
                       },
                       query: :text,
                       results: 'items',
                       text: lambda { |result|
                         result['prefLabel'][I18n.locale.to_s] ||
                          result['prefLabel'][I18n.default_locale.to_s] ||
                          result['prefLabel'][''] ||
                          result['prefLabel'].values.first
                       },
                       value: 'id'
    end
  end
end
