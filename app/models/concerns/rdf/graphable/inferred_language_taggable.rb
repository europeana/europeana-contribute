# frozen_string_literal: true

module RDF
  module Graphable
    module InferredLanguageTaggable
      extend ActiveSupport::Concern

      class_methods do
        def infer_rdf_language_tag_options
          @infer_rdf_language_tag_options ||= {}
        end

        def infers_rdf_language_tag_from(method, **options)
          @infer_rdf_language_tag_options = options.merge(from: method)
        end
      end

      def infer_rdf_language_tag(on: nil)
        options = self.class.infer_rdf_language_tag_options
        return nil if options[:from].nil?
        return nil if on && !options[:on].nil? && !Array(options[:on]).include?(on)
        send(options[:from])
      end
    end
  end
end
