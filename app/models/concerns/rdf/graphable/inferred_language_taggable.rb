# frozen_string_literal: true

module RDF
  module Graphable
    # Infer RDF language tags from a model attribute, e.g. dc:language
    #
    # @example
    #   class MyDocument
    #     include Mongoid::Document
    #     include RDF::Graphable::InferredLanguageTaggable
    #
    #     field :dc_language, type: String
    #     field :dc_title, type: String
    #     field :dc_date, type: Date
    #
    #     infers_rdf_language_tag_from(:dc_language, on: :dc_title)
    #   end
    #
    #   doc = MyDocument.new(dc_language: 'en', dc_title: 'My Title', dc_date: Date.today)
    #
    #   doc.infer_rdf_language_tag #=> 'en'
    #   doc.infer_rdf_language_tag(on: :dc_title) #=> 'en'
    #   doc.infer_rdf_language_tag(on: :dc_date) #=> nil
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
        language = send(options[:from])
        if language.is_a?(Array)
          return nil if language.size > 1
          language.first
        else
          language
        end
      end
    end
  end
end
