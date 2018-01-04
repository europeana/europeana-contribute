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

      protected

      def index_result_text(result)
        candidates = index_result_text_candidates(result)

        index_result_text_matching_query(candidates) ||
          index_result_text_present(candidates)
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
        regex = /\b#{params[:q]}/i

        candidates.each do |candidate|
          match = [candidate].flatten.detect { |value| !!(value =~ regex) }
          return match unless match.nil?
        end

        nil
      end

      # Find and the first non-blank candidate
      def index_result_text_present(candidates)
        candidates.each do |candidate|
          present = [candidate].flatten.detect { |value| value.present? }
          return present unless present.nil?
        end

        nil
      end
    end
  end
end
