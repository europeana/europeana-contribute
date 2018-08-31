# frozen_string_literal: true

module RDF
  module Graphable
    # Literalisation of RDF graphs
    #
    # @example Reduce to a single literal sparse RDF graphs.
    #
    #   An RDF graph is considered sparse if one of the specified RDF predicates
    #   is the only one present on the graph, and there is only one statement with
    #   that predicate. The presence of RDF:type is ignored when making these checks.
    #
    #   Runs after the +graph+ callback.
    #
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
    #
    # @example Force literals to be untyped
    #
    #   class MyDocument
    #     include Mongoid::Document
    #     include Mongoid::Uuid
    #     include RDF::Graphable
    #     include RDF::Graphable::Literalisation
    #
    #     field :dcterms_created, type: Date
    #
    #     def self.rdf_type
    #       "http://www.example.org/#{self.class.to_s}"
    #     end
    #   end
    #
    #   class MyDocumentWithUntypedLiterals < MyDocument
    #     graphs_rdf_literals_untyped
    #   end
    #
    #   doc = MyDocument.new(dcterms_created: Date.today)
    #   doc.to_rdf.query(predicate: RDF::Vocab::DC.created).first.object
    #   #=> #<RDF::Literal::Date:...("2018-07-26"^^<http://www.w3.org/2001/XMLSchema#date>)
    #
    #   doc = MyDocumentWithUntypedLiterals.new(dcterms_created: Date.today)
    #   doc.to_rdf.query(predicate: RDF::Vocab::DC.created).first.object
    #   #=> #<RDF::Literal:...("2018-07-26")>
    module Literalisation
      extend ActiveSupport::Concern

      class_methods do
        def graphs_as_literal(*predicates, **options)
          if __callbacks.key?(:graph)
            predicates.each do |predicate|
              callback_proc = proc { literalise_rdf_graph!(predicate) }
              set_callback :graph, :after, callback_proc, options
            end
          end
        end

        # Removes typing from all RDF literals in the graph
        def graphs_rdf_literals_untyped
          set_callback :graph, :after do
            rewrite_rdf_graph_statements do |statement|
              if statement.object.literal? && statement.object.typed?
                statement.object = RDF::Literal.new(statement.object.value)
              end
            end
          end
        end

        # Removes empty language tags from all RDF literals in the graph
        def graphs_rdf_literals_without_empty_language_tag
          set_callback :graph, :after do
            rewrite_rdf_graph_statements do |statement|
              if statement.object.literal? && statement.object.language == :''
                statement.object = RDF::Literal.new(statement.object.value)
              end
            end
          end
        end
      end

      # Converts +rdf_graph+ to a literal if sparse
      def literalise_rdf_graph!(predicate)
        self.rdf_graph = literalise_rdf_graph(predicate)
      end

      def literalise_rdf_graph(predicate)
        return rdf_graph unless rdf_graph.is_a?(RDF::Graph)

        if literalise_rdf_graph_for_predicate?(predicate)
          literalise_rdf_graph_for_predicate(predicate)
        else
          rdf_graph
        end
      end

      def literalise_rdf_graph_for_predicate?(predicate)
        return false unless rdf_graph.is_a?(RDF::Graph)

        predicated_statements = rdf_graph.query(predicate: predicate)
        return false unless predicated_statements.count == 1

        rdf_type_statements = rdf_graph.query(predicate: RDF.type)
        (rdf_graph.statements.count - (rdf_type_statements.count + predicated_statements.count)).zero?
      end

      def literalise_rdf_graph_for_predicate(predicate)
        return rdf_graph unless rdf_graph.is_a?(RDF::Graph)

        rdf_graph.query(predicate: predicate)&.first&.object
      end
    end
  end
end
