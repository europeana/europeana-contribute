# frozen_string_literal: true

module Vocabularies
  class UNESCOController < VocabulariesController
    vocabulary_index url: 'http://vocabularies.unesco.org/browser/rest/v1/thesaurus/search',
                     params: {
                       format: 'application/ld+json', lang: 'en', maxhits: 10
                     },
                     query: :query,
                     results: 'results',
                     text: 'prefLabel',
                     value: 'uri'

    protected

    def index_query
      "#{params[:q]}*"
    end
  end
end
