# frozen_string_literal: true

# @see https://github.com/europeana/corelib/wiki/EDMObjectTemplatesProviders#oreAggregation
# TODO: index edm:provider and edm:dataProvider
# TODO: make edm:dataProvider and edm:Provider configurable
module ORE
  class Aggregation
    include Mongoid::Document
    include Mongoid::Timestamps
    include Blankness::Mongoid
    include RDF::Graphable

    field :dc_rights, type: String
    field :edm_dataProvider, type: String, default: 'Europeana Foundation'
    field :edm_intermediateProvider, type: String
    field :edm_isShownAt, type: String
    field :edm_object, type: String
    field :edm_provider, type: String, default: 'Europeana Foundation'
    field :edm_ugc, type: String, default: 'true'

    index(edm_dataProvider: 1)
    index(edm_provider: 1)
    index(created_at: 1)
    index(updated_at: 1)
    index('edm_aggregatedCHO.edm_type': 1)
    index('edm_aggregatedCHO.edm_wasPresentAt_id': 1)

    belongs_to :edm_aggregatedCHO,
               class_name: 'EDM::ProvidedCHO', inverse_of: :edm_aggregatedCHO_for,
               autobuild: true, dependent: :destroy, touch: true
    belongs_to :edm_isShownBy,
               class_name: 'EDM::WebResource', inverse_of: :edm_isShownBy_for,
               optional: true, dependent: :destroy, touch: true
    belongs_to :edm_rights,
               class_name: 'CC::License', inverse_of: :edm_rights_for_ore_aggregations
    has_and_belongs_to_many :edm_hasViews,
                            class_name: 'EDM::WebResource', inverse_of: :edm_hasView_for,
                            dependent: :destroy
    has_one :story,
            class_name: 'Story', inverse_of: :ore_aggregation

    accepts_nested_attributes_for :edm_aggregatedCHO, :edm_isShownBy
    accepts_nested_attributes_for :edm_hasViews, allow_destroy: true

    rejects_blank :edm_isShownBy, :edm_hasViews
    is_present_unless_blank :edm_isShownBy, :edm_hasViews, :edm_aggregatedCHO, :edm_rights

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
    validates_associated :edm_aggregatedCHO, :edm_isShownBy, :edm_hasViews

    rails_admin do
      visible false

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

    def edm_web_resources
      [edm_isShownBy, edm_hasViews].flatten.compact
    end

    def rdf_uri
      RDF::URI.new("https://stories.europeana.eu/stories/#{edm_aggregatedCHO.uuid}")
    end
  end
end
