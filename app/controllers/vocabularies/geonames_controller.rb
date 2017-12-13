# frozen_string_literal: true

module Vocabularies
  class GeonamesController < VocabulariesController
    vocabulary_index url: 'https://secure.geonames.org/search',
                     params: {
                       username: Rails.application.secrets.geonames_api_username,
                       style: 'SHORT', type: 'json', maxRows: 10, continentCode: 'EU'
                     },
                     query: :name,
                     results: 'geonames',
                     text: 'toponymName',
                     value: ->(result) { "http://sws.geonames.org/#{result['geonameId']}" }
  end
end
