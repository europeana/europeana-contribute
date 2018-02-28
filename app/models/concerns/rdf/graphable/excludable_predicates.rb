# frozen_string_literal: true

module RDF
  module Graphable
    # Exclude RDF statements by predicate
    #
    # @example
    #   class MyDocument
    #     include RDF::Graphable::ExcludablePredicates
    #
    #     excludes_from_rdf_output(RDF::Vocab::FOAF.mbox)
    #   end
    #
    #   doc = MyDocument.new
    #   doc.exclude_from_rdf_output?(RDF::Vocab::FOAF.name) #=> false
    #   doc.exclude_from_rdf_output?(RDF::Vocab::FOAF.mbox) #=> true
    module ExcludablePredicates
      extend ActiveSupport::Concern
      include ConditionalAtRuntime

      class_methods do
        def excludes_from_rdf_output(*predicates, **options)
          predicates.each do |predicate|
            excluded_from_rdf_output[predicate] = options
          end
        end

        def excluded_from_rdf_output
          @excluded_from_rdf_output ||= {}
        end
      end

      def exclude_from_rdf_output?(predicate)
        return false unless self.class.excluded_from_rdf_output.key?(predicate)
        options = self.class.excluded_from_rdf_output[predicate]
        _options_permit_execution?(options)
      end
    end
  end
end
