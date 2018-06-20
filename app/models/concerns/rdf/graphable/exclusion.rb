# frozen_string_literal: true

module RDF
  module Graphable
    # Exclude RDF statements by predicate
    #
    # Runs run during the +graph+ callback.
    #
    # @example
    #   class MyDocument
    #     include Mongoid::Document
    #     include RDF::Graphable
    #     include RDF::Graphable::Exclusion
    #
    #     field :foaf_mbox, type: String
    #     field :foaf_name, type: String
    #
    #     graphs_without(RDF::Vocab::FOAF.mbox)
    #   end
    #
    #   doc = MyDocument.new(foaf_mbox: 'me@example.org', foaf_name: 'My Name')
    #   doc.graph
    #   doc.rdf_graph.query(predicate: RDF::Vocab::FOAF.name).count #=> 1
    #   doc.rdf_graph.query(predicate: RDF::Vocab::FOAF.mbox).count #=> 0
    module Exclusion
      extend ActiveSupport::Concern

      class_methods do
        def graphs_without(*predicates, **options)
          predicates.each do |predicate|
            callback_proc = proc { exclude_rdf_predicate!(predicate) }
            set_callback :graph, :before, callback_proc, options
          end
        end
      end

      def exclude_rdf_predicate!(predicate)
        rdf_fields_and_predicates.delete(rdf_fields_and_predicates.key(predicate))
      end
    end
  end
end
