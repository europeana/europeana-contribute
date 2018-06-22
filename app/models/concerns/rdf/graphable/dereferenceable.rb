# frozen_string_literal: true

module RDF
  module Graphable
    # Dereference RDF statements if their value matches the provided 'only' regex.
    # If no regex is provided it will only attempt to dereference values starting with "http://" or "https://".
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
    #     dereferences RDF::Vocab::DC.spatial, only: %r(\Ahttp://www.example.org/)
    #   end
    #
    #   doc = MyDocument.new(dcterms_spatial: 'http://www.example.org/rdf_element)
    #   doc.graph
    #   doc.rdf_graph.query(predicate: RDF::Vocab::DC.spatial) #=> rdf
    module Dereferenceable
      extend ActiveSupport::Concern

      class_methods do
        def dereference_only_restrictions
          @dereference_only_restrictions ||= {}
        end

        def dereferences(*predicates, **options)
          only_restriction = options.delete(:only) || %r(\Ahttps?://)

          predicates.each do |predicate|
            dereference_only_restrictions[predicate] = only_restriction
            callback_proc = proc { dereference_rdf_graph!(predicate) }
            set_callback :graph, :after, callback_proc, options
          end
        end
      end

      # Dereferences +rdf_graph+ if it is dereferenceable
      def dereference_rdf_graph!(predicate)
        self.rdf_graph = dereference_rdf_graph(predicate)
      end

      def dereference_rdf_graph(predicate)
        return rdf_graph unless rdf_graph.is_a?(RDF::Graph)
        dereference_rdf_graph_for_predicate(predicate)
      end

      def dereference_rdf_graph_for_predicate(predicate)
        return rdf_graph unless rdf_graph.is_a?(RDF::Graph)
        rdf_graph.query(predicate: predicate).each do |statement|
          next unless dereferenceable?(predicate, statement.object)
          begin
            rdf_graph << RDF::Graph.load(statement.object)
          rescue IOError, RDF::FormatError, ArgumentError, SocketError => error
            Rails.logger.debug("Unable to dereference: #{statement.object}, because of #{error}")
          end
        end
        rdf_graph
      end

      def dereferenceable?(predicate, value)
        self.class.dereference_only_restrictions[predicate].match?(value)
      end
    end
  end
end
