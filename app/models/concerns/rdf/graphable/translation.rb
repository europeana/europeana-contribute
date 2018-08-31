# frozen_string_literal: true

module RDF
  module Graphable
    module Translation
      extend ActiveSupport::Concern

      class_methods do
        def graphs_translated(*predicates, **options)
          callback_options = options.slice!(:with, :to)

          predicates.each do |predicate|
            callback_proc = proc { translate_rdf_graph(predicate, options) }
            set_callback :graph, :after, callback_proc, callback_options
          end
        end
      end

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
