# frozen_string_literal: true

module RDFModel
  extend ActiveSupport::Concern

  def rdf_namespace_prefixes
    {
      dc: RDF::Vocab::DC11.to_s,
      dcterms: RDF::Vocab::DC.to_s,
      edm: RDF::Vocab::EDM.to_s,
      foaf: RDF::Vocab::FOAF.to_s,
      ore: RDF::Vocab::ORE.to_s,
      skos: RDF::Vocab::SKOS.to_s,
      wgs84_pos: 'http://www.w3.org/2003/01/geo/wgs84_pos#',
      rdaGr2: 'http://rdvocab.info/ElementsGr2/'
    }
  end

  def to_rdfxml(**options)
    rdf_graph_to_rdfxml(to_rdf, options)
  end

  def rdf_graph_to_rdfxml(graph, options = {})
    options.reverse_merge!(prefixes: rdf_namespace_prefixes, max_depth: 0)
    graph.dump(:rdfxml, options)
  end

  def rdf_uri
    @rdf_uri ||= begin
      model_name = self.class.to_s.demodulize.underscore
      RDF::URI.new("http://stories.europeana.eu/#{model_name}/#{id}")
    end
  end

  def rdf_uri_or_literal(value)
    uri = RDF::URI.parse(value)
    uri.scheme.nil? ? value : uri
  end
end
