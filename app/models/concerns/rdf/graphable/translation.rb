# frozen_string_literal: true

module RDF
  module Graphable
    # Translate RDF statements' predicate and/or object when constructing graphs.
    #
    # Runs after the +graph+ callback.
    #
    # @example
    #   class MyDocument
    #     include Mongoid::Document
    #     include RDF::Graphable
    #     include RDF::Graphable::Translation
    #
    #     field :foaf_name, type: String
    #
    #     graphs_translated RDF::Vocab::FOAF.name,
    #                       with: ->(value) { RDF::Literal.new(value.to_s.upcase) },
    #                       to: RDF::Vocab::DC.creator
    #   end
    #
    #   doc = MyDocument.new(foaf_name: 'agustin moles')
    #   doc.graph
    #   doc.rdf_graph.query(predicate: RDF::Vocab::DC.creator).first.object #=> "AGUSTIN MOLES"
    #   doc.rdf_graph.query(predicate: RDF::Vocab::FOAF.name).count #=> 0
    module Translation
      extend ActiveSupport::Concern

      class_methods do
        # Class performs translation of some of its RDF statements
        #
        # @param [Array<RDF::URI>] *predicates RDF predicates to translate
        # @param [Hash] **options translation options; any not specified below
        #   are passed on to +.set_callback+
        # @option options [Proc] :with translate the object of the RDF statement
        #   with this lambda, passed the object as its argument, and returning
        #   a valid value to use as the object of an RDF statement, e.g.
        #   an instance of +RDF::Literal+.
        # @option options [RDF::URI] :to translate the predicate of the RDF
        #   statement to this URI.
        def graphs_translated(*predicates, **options)
          callback_options = options.slice!(:with, :to)

          predicates.each do |predicate|
            callback_proc = proc { translate_rdf_graph(predicate, options) }
            set_callback :graph, :after, callback_proc, callback_options
          end
        end
      end

      # Perform translation on this instance's RDF graph
      #
      # @param [RDF::URI] predicate RDF predicate to translate
      # @param [Hash] options (see .graphs_translated)
      def translate_rdf_graph(predicate, **options)
        return rdf_graph unless rdf_graph.is_a?(RDF::Graph)
        return rdf_graph unless options[:to] || options[:with]

        deletes = []
        inserts = []

        rdf_graph.query(predicate: predicate).each do |statement|
          deletes.push(statement.dup)
          statement.predicate = options[:to] if options[:to]
          statement.object = options[:with].call(statement.object) if options[:with].is_a?(Proc)
          inserts.push(statement)
        end

        rdf_graph.delete_insert(deletes, inserts)

        rdf_graph
      end
    end
  end
end
