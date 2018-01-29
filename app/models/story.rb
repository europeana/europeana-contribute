# frozen_string_literal: true

##
# A story is the primary data type in Europeana::Stories
#
# It is a subclass of ORE::Aggregation, with additional domain-specific
# functions not strictly relevant to that parent class.
class Story < ORE::Aggregation
  has_rdf_type RDF::Vocab::ORE.Aggregation

  def to_oai_edm
    rdf = remove_sensitive_rdf(to_rdf)
    xml = rdf_graph_to_rdfxml(rdf)
    xml.sub(/<\?xml .*? ?>/, '').strip
  end

  # Remove contributor name and email from RDF
  def remove_sensitive_rdf(rdf)
    unless edm_aggregatedCHO&.dc_contributor.nil?
      contributor_uri = edm_aggregatedCHO.dc_contributor.rdf_uri
      contributor_mbox = rdf.query(subject: contributor_uri, predicate: RDF::Vocab::FOAF.mbox)
      contributor_name = rdf.query(subject: contributor_uri, predicate: RDF::Vocab::FOAF.name)
      rdf.delete(contributor_mbox, contributor_name)
    end

    rdf
  end

  # OAI-PMH set(s) this aggregation is in
  def sets
    Europeana::Stories::OAI::Model.sets.select do |set|
      set.name == edm_provider
    end
  end
end
