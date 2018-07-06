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
                       text: :index_result_text,
                       value: 'id'

      # TODO: individual entity retrieval from API does not include isPartOf :(
      vocabulary_show url: ->(uri) { Rails.application.config.x.europeana.entities.api_url + '/entities' + uri.path },
                      params: {
                        wskey: Rails.application.secrets.europeana_entities_api_key
                      },
                      text: :show_text

      protected

      def show_text(response)
        index_result_text(response)
      end

      # Override +VocabulariesController#index_data+ to remove unwanted entity
      def index_data(json)
        super.reject { |result| %r(http://data.europeana.eu/place/(base/)?177348).match?(result[:value]) }
      end

      def index_result_text(result)
        candidates = index_result_text_candidates(result)

        result_text = index_result_text_matching_query(candidates) ||
                      index_result_text_present(candidates)

        return result_text unless result.key?('isPartOf')

        result_parents = result['isPartOf'].map { |ipo| index_result_text_candidates(ipo) }.map(&:first).flatten.compact
        result_parents.unshift(result_text).join(', ')
      end

      def index_result_text_candidates(result)
        result['altLabel'] ||= {}
        [
          result['prefLabel'][I18n.locale.to_s],
          result['altLabel'][I18n.locale.to_s],
          result['prefLabel'][I18n.default_locale.to_s],
          result['altLabel'][I18n.default_locale.to_s],
          result['prefLabel'][''],
          result['altLabel'][''],
          result['prefLabel'].values,
          result['altLabel'].values
        ]
      end

      # Find and return the first candidate matching the regex
      def index_result_text_matching_query(candidates)
        return nil unless params.key?(:q)
        query = params[:q].downcase

        candidates.each do |candidate|
          match = [candidate].flatten.compact.detect do |value|
            value.downcase.split(/\b/).any? { |fragment| fragment.start_with?(query) }
          end
          return match unless match.nil?
        end

        nil
      end

      # Find and the first non-blank candidate
      def index_result_text_present(candidates)
        candidates.each do |candidate|
          present = [candidate].flatten.detect(&:present?)
          return present unless present.nil?
        end

        nil
      end
    end
  end
end
