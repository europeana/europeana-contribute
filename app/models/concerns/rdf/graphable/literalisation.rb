# frozen_string_literal: true

module RDF
  module Graphable
    # Reduces to a single literal sparse RDF graphs
    #
    # Will run during the +graph+ callback if defined on the including model.
    #
    # @example
    #   class MyDocument
    #     include Mongoid::Document
    #     include RDF::Graphable
    #     include RDF::Graphable::Literalisation
    #
    #     field :dc_title, type: String
    #     field :dc_description, type: String
    #
    #     graphs_as_literal RDF::Vocab::DC11.title
    #   end
    #
    #   doc = MyDocument.new(dc_title: 'My Title', dc_description: 'My description')
    #   doc.graph #=> #<RDF::Graph:...>
    #
    #   doc = MyDocument.new(dc_title: 'My Title')
    #   doc.graph #=> #<RDF::Literal:...("My Title")>
    module Literalisation
      extend ActiveSupport::Concern

      class_methods do
        def graphs_as_literal(*predicates, **options)
          if __callbacks.key?(:graph)
            class_eval do
              predicates.each do |predicate|
                callback_proc = proc { literalise_rdf_graph!(predicate) }
                set_callback :graph, :after, callback_proc, options
              end
            end
          end
        end

        def literalise_rdf_graph(graph, predicate)
          return graph unless graph.is_a?(RDF::Graph)

          predicated_statements = graph.query(predicate: predicate)
          return graph unless predicated_statements.count == 1

          rdf_type_statements = graph.query(predicate: RDF.type)
          if (graph.statements.count - (rdf_type_statements.count + predicated_statements.count)).zero?
            return predicated_statements.first.object
          end

          graph
        end
      end

      # Converts +rdf_graph+ to a literal if sparse
      def literalise_rdf_graph!(predicate)
        self.rdf_graph = self.class.literalise_rdf_graph(self.rdf_graph, predicate)
      end
    end
  end
end
