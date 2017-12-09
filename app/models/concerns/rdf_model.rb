# frozen_string_literal: true

module RDFModel
  extend ActiveSupport::Concern

  class_methods do
    attr_reader :rdf_type

    def has_rdf_type(rdf_type)
      @rdf_type = rdf_type
    end

    def rdf_fields_and_predicates
      @rdf_fields_and_predicates ||= begin
        (fields.keys + relations.keys).each_with_object({}) do |field_name, memo|
          memo[field_name] = rdf_predicate_for_field(field_name)
        end.reject do |field_name, rdf_predicate|
          rdf_predicate.nil?
        end
      end
    end

    def rdf_predicate_for_field(field_name)
      rdf_prefixed_vocabularies.each do |prefix, vocab|
        match = field_name.to_s.match(/\A#{prefix}_(.+)\z/)
        next if match.nil?
        return vocab.send(match[1]) if vocab.respond_to?(match[1])
      end
      nil
    end

    # TODO: create vocabs for rdaGr2 and wgs84_pos
    def rdf_prefixed_vocabularies
      {
        dc: RDF::Vocab::DC11,
        dcterms: RDF::Vocab::DC,
        edm: RDF::Vocab::EDM,
        foaf: RDF::Vocab::FOAF,
        ore: RDF::Vocab::ORE,
        skos: RDF::Vocab::SKOS,
        wgs84_pos: 'http://www.w3.org/2003/01/geo/wgs84_pos#',
        rdaGr2: 'http://rdvocab.info/ElementsGr2/'
      }
    end

    def rdf_namespace_prefixes
      @rdf_namespace_prefixes ||= begin
        rdf_prefixed_vocabularies.each_with_object({}) do |(k, v), memo|
          memo[k] = v.to_s
        end
      end
    end
  end

  def to_rdf
    RDF::Graph.new.tap do |graph|
      graph << [rdf_uri, RDF.type, self.class.rdf_type]
      self.class.rdf_fields_and_predicates.each do |field_name, rdf_predicate|
        field_value = send(field_name)
        next if field_value.nil? || field_value == ''

        graph << [rdf_uri, rdf_predicate, rdf_uri_or_literal(field_value)]

        if field_value.respond_to?(:to_rdf)
          relation_graph = field_value.to_rdf
          graph.insert(relation_graph) unless relation_graph.size == 1
        end
      end
    end
  end

  def to_rdfxml(**options)
    rdf_graph_to_rdfxml(to_rdf, options)
  end

  def rdf_graph_to_rdfxml(graph, options = {})
    options.reverse_merge!(prefixes: self.class.rdf_namespace_prefixes, max_depth: 0)
    graph.dump(:rdfxml, options)
  end

  def rdf_uri
    @rdf_uri ||= begin
      model_name = self.class.to_s.demodulize.underscore
      RDF::URI.new("http://stories.europeana.eu/#{model_name}/#{id}")
    end
  end

  def rdf_uri_or_literal(value)
    return value.rdf_uri if value.respond_to?(:rdf_uri)
    uri = RDF::URI.parse(value)
    uri.scheme.nil? ? value : uri
  end
end
