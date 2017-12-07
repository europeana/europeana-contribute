# frozen_string_literal: true

# @see https://github.com/europeana/corelib/wiki/EDMObjectTemplatesProviders#oreAggregation
# TODO: index edm:provider and edm:dataProvider
module ORE
  class Aggregation
    include Mongoid::Document
    include Mongoid::Timestamps
    include RDFModel

    field :dc_rights, type: String
    field :edm_dataProvider, type: String
    field :edm_intermediateProvider, type: String
    field :edm_isShownAt, type: String
    field :edm_object, type: String
    field :edm_provider, type: String
    field :edm_ugc, type: String, default: 'true'

    embeds_one :edm_aggregatedCHO, class_name: 'EDM::ProvidedCHO'
    embeds_one :edm_isShownBy, class_name: 'EDM::WebResource', inverse_of: :edm_isShownBy_for, cascade_callbacks: true
    embeds_many :edm_hasViews, class_name: 'EDM::WebResource', inverse_of: :edm_hasViews_for, cascade_callbacks: true

    belongs_to :edm_rights, class_name: 'CC::License', inverse_of: :ore_aggregations

    accepts_nested_attributes_for :edm_aggregatedCHO, :edm_isShownBy, :edm_hasViews

    class << self
      def edm_ugc_enum
        %w(true false)
      end
    end

    delegate :edm_ugc_enum, to: :class
    delegate :dc_title, to: :edm_aggregatedCHO
    delegate :media, to: :edm_isShownBy

    validates :edm_ugc, inclusion: { in: edm_ugc_enum }
    validates :edm_provider, :edm_dataProvider, presence: true
    validates :edm_isShownAt, presence: true, unless: :edm_isShownBy?
    validates :edm_isShownBy, presence: true, unless: :edm_isShownAt?

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
      graph = to_rdf

      [
        edm_aggregatedCHO,
        edm_aggregatedCHO.dc_creator,
        edm_aggregatedCHO.dc_contributor
      ].each do |relation|
        next if relation.blank?
        # omit local objects having only one RDF statement, i.e. their rdf:type
        relation_graph = relation.to_rdf
        graph.insert(relation_graph) unless relation_graph.size == 1
      end

      xml = rdf_graph_to_rdfxml(graph)
      xml.sub(/<\?xml .*? ?>/, '')
    end

    def to_rdf
      RDF::Graph.new.tap do |graph|
        graph << [rdf_uri, RDF.type, RDF::Vocab::ORE.Aggregation]
        graph << [rdf_uri, RDF::Vocab::EDM.provider, edm_provider]
        graph << [rdf_uri, RDF::Vocab::EDM.dataProvider, edm_dataProvider]
        graph << [rdf_uri, RDF::Vocab::EDM.rights, edm_rights.rdf_uri]
        graph << [rdf_uri, RDF::Vocab::EDM.isShownBy, RDF::URI.new(edm_isShownBy.media)]
        graph << [rdf_uri, RDF::Vocab::EDM.aggregatedCHO, edm_aggregatedCHO.rdf_uri]
        graph << [rdf_uri, RDF::Vocab::EDM.ugc, edm_ugc]
      end
    end
  end
end
