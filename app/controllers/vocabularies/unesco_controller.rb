# frozen_string_literal: true

module Vocabularies
  class UNESCOController < VocabulariesController
    vocabulary_index url: 'http://vocabularies.unesco.org/browser/rest/v1/thesaurus/search',
                     params: {
                       format: 'application/ld+json', lang: 'en', maxhits: 10, type: 'skos:Concept'
                     },
                     query: :query,
                     results: 'results',
                     text: :index_result_text,
                     value: 'uri'

    vocabulary_show url: 'http://vocabularies.unesco.org/browser/rest/v1/thesaurus/data',
                    params: {
                      format: 'application/json',
                      uri: ->(uri) { uri.to_s }
                    },
                    text: :show_text

    protected

    def show_text(response)
      item_data = response['graph'].detect { |item| item['uri'] == params['uri'] }

      translation = item_data['prefLabel'].detect { |pl| pl['lang'] == I18n.locale.to_s } ||
                    item_data['prefLabel'].detect { |pl| pl['lang'] == I18n.default_locale.to_s } ||
                    item_data['prefLabel'].first

      translation['value']
    end

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
