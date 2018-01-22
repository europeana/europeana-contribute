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

    embeds_one :edm_aggregatedCHO, class_name: 'EDM::ProvidedCHO', autobuild: true, cascade_callbacks: true
    embeds_one :edm_isShownBy, class_name: 'EDM::WebResource', inverse_of: :edm_isShownBy_for, cascade_callbacks: true
    embeds_many :edm_hasViews, class_name: 'EDM::WebResource', inverse_of: :edm_hasViews_for, cascade_callbacks: true

    belongs_to :edm_rights, class_name: 'CC::License', inverse_of: :ore_aggregations

    accepts_nested_attributes_for :edm_aggregatedCHO, :edm_isShownBy, reject_if: :all_blank
    accepts_nested_attributes_for :edm_hasViews, reject_if: :all_blank, allow_destroy: true

    omit_blank_association :edm_hasViews, :edm_isShownBy

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
      xml = rdf_graph_to_rdfxml(to_rdf)
      xml.sub(/<\?xml .*? ?>/, '').strip
    end

    # OAI-PMH set(s) this aggregation is in
    def sets
      Europeana::Stories::OAI::Model.sets.select do |set|
        set.name == edm_provider
      end
    end
  end
end
