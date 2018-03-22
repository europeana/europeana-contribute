# frozen_string_literal: true

module RDF
  # Convenience methods for dumping models to RDF.
  #
  # Including classes are expected to implement +#to_rdf+ to return an
  # +RDF::Graph+.
  module Dumpable
    extend ActiveSupport::Concern

    def to_jsonld
      to_rdf.dump(:jsonld, prefixes: Graphable::PREFIXED_VOCABULARIES.dup)
    end

    def to_turtle
      to_rdf.dump(:turtle, prefixes: Graphable::PREFIXED_VOCABULARIES.dup)
    end

    def to_ntriples
      to_rdf.dump(:ntriples, prefixes: Graphable::PREFIXED_VOCABULARIES.dup)
    end

    def to_rdfxml
      options = {
        prefixes: Graphable::PREFIXED_VOCABULARIES.dup,
        max_depth: 0,
        haml_options: { format: :xhtml, attr_wrapper: '"' }
      }

      to_rdf.dump(:rdfxml, options)
    end

    def to_oai_edm
      to_rdfxml.sub(/<\?xml .*? ?>/, '').strip
    end

    def to_rdf
      fail "#{self.class} needs to implement #to_rdf"
    end
  end
end
