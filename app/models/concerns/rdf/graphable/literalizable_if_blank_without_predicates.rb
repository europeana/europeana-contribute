# frozen_string_literal: true

module RDF
  module Graphable
    # Reduces to a single literal sparse RDF graphs
    #
    # @example
    #   class MyDocument
    #     include Mongoid::Document
    #     include RDF::Graphable::LiteralizableIfBlankWithoutPredicates
    #
    #     field :dc_title, type: String
    #     field :dc_description, type: String
    #
    #     is_rdf_literal_if_blank_without(RDF::Vocab::DC11.title)
    #
    #     def to_rdf
    #       uri = RDF::URI.new(id)
    #       graph = RDF::Graph.new
    #       graph << [uri, RDF::Vocab::DC11.title, dc_title] unless dc_title.nil?
    #       graph << [uri, RDF::Vocab::DC11.description, dc_description] unless dc_description.nil?
    #       graph
    #     end
    #   end
    #
    #   doc = MyDocument.new(dc_title: 'My Title', dc_description: 'My description')
    #   doc.literalized_rdf_graph(doc.to_rdf) #=> nil
    #
    #   doc = MyDocument.new(dc_title: 'My Title')
    #   doc.literalized_rdf_graph(doc.to_rdf) #=> #<RDF::Literal:...("My Title")>
    module LiteralizableIfBlankWithoutPredicates
      extend ActiveSupport::Concern
      include ConditionalAtRuntime

      class_methods do
        def is_rdf_literal_if_blank_without(*predicates, **options)
          predicates.each do |predicate|
            rdf_literal_if_blank_without[predicate] = options
          end
        end

        def rdf_literal_if_blank_without
          @rdf_literal_if_blank_without ||= {}
        end
      end

      def literalized_rdf_graph(graph)
        return nil unless graph.count <= 2

        graph.each do |stmt|
          next if stmt.predicate == RDF.type
          return nil unless self.class.rdf_literal_if_blank_without.key?(stmt.predicate)
          options = self.class.rdf_literal_if_blank_without[stmt.predicate]
          return nil unless _options_permit_execution?(options)
          return stmt.object
        end

        nil
      end
    end
  end
end
