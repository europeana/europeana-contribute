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
    #     include RDF::Graphable::Sparsity
    #
    #     attr_accessor :rdf_graph
    #
    #     field :dc_title, type: String
    #     field :dc_description, type: String
    #
    #     is_sparse_rdf_with_only(RDF::Vocab::DC11.title)
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
    #   doc.rdf_graph = doc.to_rdf
    #   doc.literalize_rdf_graph! #=> #<RDF::Graph:...>
    #
    #   doc = MyDocument.new(dc_title: 'My Title')
    #   doc.rdf_graph = doc.to_rdf
    #   doc.literalize_rdf_graph! #=> #<RDF::Literal:...("My Title")>
    module Sparsity
      extend ActiveSupport::Concern

      class_methods do
        def is_sparse_rdf_with_only(*predicates, **options)
          sparse_rdf_predicates.push(*predicates)
          set_callback :graph, :after, :literalize_rdf_graph!, options if __callbacks.key?(:graph)
        end

        def sparse_rdf_predicates
          @sparse_rdf_predicates ||= []
        end

        def literalize_rdf_graph(graph)
          return graph unless graph.respond_to?(:count) && graph.count <= 2

          graph.each do |stmt|
            next if stmt.predicate == RDF.type
            return graph unless sparse_rdf_predicates.include?(stmt.predicate)
            return stmt.object
          end

          graph
        end
      end

      # Converts +rdf_graph+ to a literal if sparse
      def literalize_rdf_graph!
        self.rdf_graph = self.class.literalize_rdf_graph(rdf_graph)
      end
    end
  end
end
