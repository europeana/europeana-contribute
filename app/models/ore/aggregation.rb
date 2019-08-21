# frozen_string_literal: true

# @see https://github.com/europeana/corelib/wiki/EDMObjectTemplatesProviders#oreAggregation
module ORE
  class Aggregation
    include Mongoid::Document
    include Mongoid::Timestamps
    include AASM
    include ArrayOfAttributeValidation
    include Blankness::Mongoid::Attributes
    include Blankness::Mongoid::Relations
    include RDF::Graphable
    include RDF::Graphable::Literalisation

    field :aasm_state
    field :dc_rights, type: ArrayOf.type(String), default: []
    field :edm_dataProvider, type: String
    field :edm_intermediateProvider, type: String
    field :edm_isShownAt, type: String
    field :edm_object, type: String
    field :edm_provider, type: String
    field :edm_ugc, type: String, default: 'true'

    index(edm_dataProvider: 1)
    index(edm_provider: 1)
    index(created_at: 1)
    index(updated_at: 1)

    belongs_to :edm_aggregatedCHO,
               class_name: 'EDM::ProvidedCHO', inverse_of: :edm_aggregatedCHO_for,
               index: true, autobuild: true, dependent: :destroy
    belongs_to :edm_rights,
               class_name: 'CC::License', inverse_of: :edm_rights_for_ore_aggregations
    has_many :edm_hasViews,
             class_name: 'EDM::WebResource', inverse_of: :edm_hasView_for,
             dependent: :destroy
    has_one :edm_isShownBy,
            class_name: 'EDM::WebResource', inverse_of: :edm_isShownBy_for,
            dependent: :destroy
    has_one :contribution,
            class_name: 'Contribution', inverse_of: :ore_aggregation

    accepts_nested_attributes_for :edm_aggregatedCHO, :edm_isShownBy
    accepts_nested_attributes_for :edm_hasViews, allow_destroy: true

    rejects_blank :edm_isShownBy, :edm_hasViews
    is_present_unless_blank :edm_isShownBy, :edm_hasViews, :edm_aggregatedCHO, :edm_rights

    class << self
      def edm_ugc_enum
        %w(true false)
      end
    end

    delegate :dc_language, :dc_title, to: :edm_aggregatedCHO
    delegate :edm_ugc_enum, to: :class
    delegate :media, to: :edm_isShownBy, allow_nil: true
    delegate :campaign, :ever_published?, to: :contribution, allow_nil: true

    validates :edm_ugc, inclusion: { in: edm_ugc_enum }
    validates :edm_provider, :edm_dataProvider, presence: true
    validates_associated :edm_aggregatedCHO

    graphs_rdf_literals_untyped
    graphs_rdf_literals_without_empty_language_tag

    has_rdf_predicate :edm_hasViews, RDF::Vocab::EDM.hasView

    before_save :inherit_aasm_state

    aasm do
      state :draft, initial: true
      state :published

      event :publish do
        transitions from: :draft, to: :published
        after do
          edm_aggregatedCHO.publish
          edm_isShownBy&.publish
          edm_hasViews.each(&:publish)
        end
      end

      event :unpublish do
        transitions from: :published, to: :draft
        after do
          edm_aggregatedCHO.unpublish
          edm_isShownBy&.unpublish
          edm_hasViews.each(&:unpublish)
        end
      end
    end

    def edm_web_resources
      [edm_isShownBy, edm_hasViews].flatten.compact
    end

    def rdf_uri
      RDF::URI.new("#{edm_aggregatedCHO.rdf_uri}#aggregation")
    end

    def inherit_aasm_state
      self.aasm_state = contribution&.aasm_state || aasm_state
    end
  end
end
