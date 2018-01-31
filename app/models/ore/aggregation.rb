# frozen_string_literal: true

# @see https://github.com/europeana/corelib/wiki/EDMObjectTemplatesProviders#oreAggregation
# TODO: index edm:provider and edm:dataProvider
module ORE
  class Aggregation
    include Mongoid::Document
    include Mongoid::Timestamps
    include RDFModel
    include RemoveBlankAttributes

    field :dc_rights, type: String
    field :edm_dataProvider, type: String
    field :edm_intermediateProvider, type: String
    field :edm_isShownAt, type: String
    field :edm_object, type: String
    field :edm_provider, type: String
    field :edm_ugc, type: String, default: 'true'

    index({ edm_dataProvider: 1 })
    index({ edm_provider: 1 })
    index({ created_at: 1 })
    index({ updated_at: 1 })
    index('edm_aggregatedCHO.edm_type': 1)
    index('edm_aggregatedCHO.edm_wasPresentAt_id': 1)

    embeds_one :edm_aggregatedCHO, class_name: 'EDM::ProvidedCHO', autobuild: true, cascade_callbacks: true
    embeds_one :edm_isShownBy, class_name: 'EDM::WebResource', inverse_of: :edm_isShownBy_for, cascade_callbacks: true
    embeds_many :edm_hasViews, class_name: 'EDM::WebResource', inverse_of: :edm_hasViews_for, cascade_callbacks: true

    belongs_to :edm_rights, class_name: 'CC::License', inverse_of: :ore_aggregations

    accepts_nested_attributes_for :edm_aggregatedCHO, :edm_isShownBy
    accepts_nested_attributes_for :edm_hasViews, allow_destroy: true

    class << self
      def edm_ugc_enum
        %w(true false)
      end
    end

    delegate :dc_title, to: :edm_aggregatedCHO
    delegate :edm_ugc_enum, to: :class
    delegate :media, to: :edm_isShownBy, allow_nil: true

    validates :edm_ugc, inclusion: { in: edm_ugc_enum }
    validates :edm_provider, :edm_dataProvider, presence: true
    # validates :edm_isShownAt, presence: true, unless: :edm_isShownBy?
    # validates :edm_isShownBy, presence: true, unless: :edm_isShownAt?

    rails_admin do
      list do
        field :media, :carrierwave
        field :edm_provider, :string
        field :edm_dataProvider, :string
        field :dc_title
        field :created_at
        field :updated_at
      end

      show do
        field :media, :carrierwave
        field :edm_provider, :string
        field :edm_dataProvider, :string
        field :dc_title
        field :created_at
        field :updated_at
      end

      edit do
        field :edm_provider, :string
        field :edm_dataProvider, :string
        field :edm_intermediateProvider, :string
        field :edm_rights do
          inline_add false
          inline_edit false
        end
        field :dc_rights
        field :edm_aggregatedCHO
        field :edm_isShownBy
        field :edm_isShownAt, :string
        field :edm_object, :string
        field :edm_hasViews
        field :edm_ugc, :enum
      end
    end

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
end
