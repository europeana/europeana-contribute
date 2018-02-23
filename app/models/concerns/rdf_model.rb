# frozen_string_literal: true

module RDFModel
  extend ActiveSupport::Concern

  class_methods do
    # Set override for the RDF predicate to map a field to.
    #
    # Useful when the RDF predicate can not be deduced from the field name.
    #
    # @example
    #   class EDM::ProvidedCHO
    #     include Mongoid::Document
    #     field :dc_subject_agents, class_name: 'EDM::Agent'
    #     has_rdf_predicate(:dc_subject_agents, RDF::Vocab::DC11.subject)
    #   end
    def has_rdf_predicate(field_name, rdf_predicate)
      rdf_predicates[field_name] = rdf_predicate
    end

    def rdf_predicates
      @rdf_predicates ||= HashWithIndifferentAccess.new
    end

    def rdf_type
      @rdf_type ||= begin
        vocab = RDF::Vocab.const_get(to_s.deconstantize)
        vocab.send(to_s.demodulize)
      end
    end

    def rdf_fields_and_predicates
      @rdf_fields_and_predicates ||= begin
        fields_and_relations.keys.each_with_object(HashWithIndifferentAccess.new) do |field_name, memo|
          memo[field_name] = rdf_predicate_for_field(field_name)
        end.reject do |field_name, rdf_predicate|
          rdf_predicate.nil?
        end
      end
    end

    def rdf_predicate_for_field(field_name)
      return rdf_predicates[field_name] if rdf_predicates.key?(field_name)

      rdf_prefixed_vocabularies.each do |prefix, vocab|
        match = field_name.to_s.match(/\A#{prefix}_(.+)\z/)
        next if match.nil?
        return vocab.respond_to?(match[1]) ? vocab.send(match[1]) : nil
      end
      nil
    end

    def rdf_prefixed_vocabularies
      {
        dc: RDF::Vocab::DC11,
        dcterms: RDF::Vocab::DC,
        edm: RDF::Vocab::EDM,
        foaf: RDF::Vocab::FOAF,
        ore: RDF::Vocab::ORE,
        owl: RDF::Vocab::OWL,
        rdaGr2: RDF::Vocab::RDAGR2,
        skos: RDF::Vocab::SKOS,
        wgs84_pos: RDF::Vocab::WGS84_POS
      }
    end

    def rdf_namespace_prefixes
      @rdf_namespace_prefixes ||= begin
        rdf_prefixed_vocabularies.each_with_object({}) do |(k, v), memo|
          memo[k] = v.to_s
        end
      end
    end

    def fields_and_relations
      @fields_and_relations ||= fields.merge(relations)
    end
  end

  included do
    delegate :rdf_fields_and_predicates, :fields_and_relations, to: :class
  end

  def to_rdf
    RDF::Graph.new.tap do |graph|
      graph << [rdf_uri, RDF.type, self.class.rdf_type]
      rdf_fields_and_predicates.each_key do |field_name|
        field = fields_and_relations[field_name]
        field_graph = rdf_graph_for_field(field)
        graph.insert(field_graph) unless field_graph.nil?
      end
    end
  end

  def rdf_graph_for_field(field)
    rdf_predicate = rdf_fields_and_predicates[field.name.to_s]

    if field.is_a?(Mongoid::Fields::Localized)
      rdf_graph_for_localized_field(field, rdf_predicate)
    else
      rdf_graph_for_unlocalized_field(field, rdf_predicate)
    end
  end

  def rdf_graph_for_localized_field(field, rdf_predicate)
    field_value = send("#{field.name}_translations")
    return if field_value.blank?

    RDF::Graph.new.tap do |graph|
      field_value.each_pair do |language, value|
        graph << [rdf_uri, rdf_predicate, rdf_uri_or_literal(value, language: language)]
      end
    end
  end

  def rdf_graph_for_unlocalized_field(field, rdf_predicate)
    field_value = send(field.name)
    return if field_value.nil? || field_value == ''

    RDF::Graph.new.tap do |graph|
      [field_value].flatten.each do |value|
        graph << [rdf_uri, rdf_predicate, rdf_uri_or_literal(value)]
        graph.insert(value.to_rdf) if value.respond_to?(:to_rdf)
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

  def rdf_uri_or_literal(value, language: nil)
    return RDF::Literal.new(value, language: language) unless language.nil?
    return value.rdf_uri if value.respond_to?(:rdf_uri)
    uri = URI.parse(value)
    uri.scheme.nil? ? value : RDF::URI.new(uri)
  rescue URI::InvalidURIError
    value
  end
end
