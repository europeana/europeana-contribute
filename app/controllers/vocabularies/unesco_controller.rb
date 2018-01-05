# frozen_string_literal: true

module Vocabularies
  class UNESCOController < VocabulariesController
    vocabulary_index url: 'http://vocabularies.unesco.org/browser/rest/v1/thesaurus/search',
                     params: {
                       format: 'application/ld+json', lang: 'en', maxhits: 10
                     },
                     query: :query,
                     results: 'results',
                     text: :index_result_text,
                     value: 'uri'

    protected

    def index_query
      "#{params[:q]}*"
    end

    # matches may be in either prefLabel or altLabel
    def index_result_text(result)
      query = params[:q].downcase

      if result['prefLabel'].downcase.start_with?(query)
        result['prefLabel']
      elsif result['altLabel'].downcase.start_with?(query)
        result['altLabel']
      else
        result['prefLabel']
      end
    end
  end
end
