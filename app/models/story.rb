# frozen_string_literal: true

##
# Primary container for the data associated with a contributed story.
class Story
  include Mongoid::Document
  include Mongoid::Timestamps
  include AASM

  belongs_to :ore_aggregation, class_name: 'ORE::Aggregation', inverse_of: :story,
                               autobuild: true, index: true, dependent: :destroy,
                               touch: true
  belongs_to :created_by, class_name: 'User', optional: true, inverse_of: :stories,
                          index: true

  field :aasm_state

  index(created_at: 1)
  index(updated_at: 1)
  index(status: 1)

  accepts_nested_attributes_for :ore_aggregation

  validates_associated :ore_aggregation

  delegate :to_rdf, :rdf_graph_to_rdfxml, to: :ore_aggregation

  aasm do
    state :draft, initial: true
    state :published, :deleted

    event :publish do
      transitions from: :draft, to: :published
    end

    event :unpublish do
      transitions from: :published, to: :draft
    end

    event :delete do
      transitions from: :draft, to: :deleted
    end
  end

  rails_admin do
    list do
      field :ore_aggregation
      field :created_at
      field :created_by
      field :updated_at
    end

    show do
      field :ore_aggregation
      field :created_at
      field :created_by
      field :updated_at
    end

    edit do
      field :ore_aggregation do
        inline_add false
      end
      field :created_at # TODO: to faciliate manual override during data migration; remove
    end
  end

  def to_oai_edm
    rdf = remove_sensitive_rdf(to_rdf)
    xml = rdf_graph_to_rdfxml(rdf)
    xml.sub(/<\?xml .*? ?>/, '').strip
  end

  # Remove contributor name and email from RDF
  def remove_sensitive_rdf(rdf)
    unless ore_aggregation&.edm_aggregatedCHO&.dc_contributor_agent.nil?
      contributor_uri = ore_aggregation.edm_aggregatedCHO.dc_contributor_agent.rdf_uri
      contributor_mbox = rdf.query(subject: contributor_uri, predicate: RDF::Vocab::FOAF.mbox)
      contributor_name = rdf.query(subject: contributor_uri, predicate: RDF::Vocab::FOAF.name)
      rdf.delete(contributor_mbox, contributor_name)
    end

    rdf
  end

  # OAI-PMH set(s) this aggregation is in
  def sets
    Europeana::Stories::OAI::Model.sets.select do |set|
      set.name == ore_aggregation.edm_provider
    end
  end

  def has_media?
    ore_aggregation.edm_web_resources.any?(&:media?)
  end
end
