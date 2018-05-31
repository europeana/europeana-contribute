# frozen_string_literal: true

module RDF
  module Graphable
    # Derference RDF statements if their value matches the URLs in DEREFERENCEABLE_URLS
    #
    # Runs during the +graph+ callback.
    #
    # @example
    #   class MyDocument
    #     include Mongoid::Document
    #     include RDF::Graphable
    #     include RDF::Graphable::Dereferenceable
    #
    #     field :dcterms_spatial, type: ArrayOf.type(String), default: []
    #
    #     dereferences RDF::Vocab::DC.spatial
    #   end
    #
    #   doc = MyDocument.new(dcterms_spatial: 'htttp://www.example.org/rdf_element)
    #   doc.graph
    #   doc.rdf_graph.query(predicate: RDF::Vocab::DC.spatial) #=> rdf
    module Dereferenceable
      extend ActiveSupport::Concern

      class_methods do
        def dereferences(*predicates, **options)
          class_eval do
            predicates.each do |predicate|
              callback_proc = proc { dereference_rdf_graph!(predicate) }
              set_callback :graph, :after, callback_proc, options
            end
          end
        end
      end

      DEREFERENCEABLE_URLS = %w(http://data.europeana.eu/place/base http://data.europeana.eu/concept/base).freeze

      # Dereferencess +rdf_graph+ to if it is dereferenceable
      def dereference_rdf_graph!(predicate)
        self.rdf_graph = dereference_rdf_graph(predicate)
      end


      def dereference_rdf_graph(predicate)
        return rdf_graph unless rdf_graph.is_a?(RDF::Graph)

        if dereference_rdf_graph_for_predicate?(predicate)
          dereference_rdf_graph_for_predicate(predicate)
        else
          rdf_graph
        end
      end

      def dereference_rdf_graph_for_predicate?(predicate)
        return false unless rdf_graph.is_a?(RDF::Graph)
        true
      end

      def dereference_rdf_graph_for_predicate(predicate)
        return rdf_graph unless rdf_graph.is_a?(RDF::Graph)
        rdf_graph.query(predicate: predicate).each do |statement|
          next unless dereferenceable?(statement.object)
          rdf_graph << RDF::Graph.load(statement.object)
        end
        rdf_graph
      end

      def dereferenceable?(value)
        DEREFERENCEABLE_URLS.any? { |url| value.start_with?(url) }
      end
    end
  end
end
