# frozen_string_literal: true

module RDF
  module Graphable
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

      def literalize_rdf_graph_if_blank(graph)
        # If only 2 statements, 1 will be rdf:type
        return graph unless graph.count == 2

        graph.each do |stmt|
          next unless self.class.rdf_literal_if_blank_without.key?(stmt.predicate)
          options = self.class.rdf_literal_if_blank_without[stmt.predicate]
          next unless _options_permit_execution?(options)
          return stmt.object
        end

        graph
      end
    end
  end
end
