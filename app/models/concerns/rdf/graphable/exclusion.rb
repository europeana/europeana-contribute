# frozen_string_literal: true

module RDF
  module Graphable
    # Exclude RDF statements by predicate
    #
    # @example
    #   class MyDocument
    #     include RDF::Graphable::Exclusion
    #
    #     graphs_without(RDF::Vocab::FOAF.mbox)
    #   end
    #
    #   doc = MyDocument.new
    #   doc.exclude_from_rdf_output?(RDF::Vocab::FOAF.name) #=> false
    #   doc.exclude_from_rdf_output?(RDF::Vocab::FOAF.mbox) #=> true
    module Exclusion
      extend ActiveSupport::Concern

      class_methods do
        def graphs_without(*predicates, **options)
          class_eval do
            predicates.each do |predicate|
              callback_proc = proc { reject_rdf_predicate!(predicate) }
              set_callback :graph, :after, callback_proc, options
            end
          end
        end
      end

      def reject_rdf_predicate!(predicate)
        self.rdf_graph.delete(predicate: predicate)
      end
    end
  end
end
