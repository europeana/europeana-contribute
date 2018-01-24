# frozen_string_literal: true

# @see https://github.com/europeana/corelib/wiki/EDMObjectTemplatesProviders#edmProvidedCHO
# TODO: EDM validations
#       - one of dc:subject, dc:type, dcterms:spatial or dcterms:temporal is mandatory
#       - either dc:description or dc:title is mandatory
module EDM
  class ProvidedCHO
    include Mongoid::Document
    include AutocompletableModel
    include CampaignValidatableModel
    include RDFModel
    include RemoveBlankAttributes

    embedded_in :ore_aggregation, class_name: 'ORE::Aggregation', inverse_of: :edm_aggregatedCHO
    embeds_one :dc_contributor, class_name: 'EDM::Agent', inverse_of: :dc_contributor_for, cascade_callbacks: true
    embeds_many :dc_subject_agents, class_name: 'EDM::Agent', inverse_of: :dc_subject_agents_for, cascade_callbacks: true
    embeds_many :dcterms_spatial_places, class_name: 'EDM::Place', inverse_of: :dcterms_spatial_places_for, cascade_callbacks: true

    field :dc_creator, type: String
    field :dc_date, type: Date
    field :dc_description, localize: true
    field :dc_identifier, type: String
    field :dc_language, type: String
    field :dc_relation, type: String
    field :dc_subject, type: String
    field :dc_title, localize: true
    field :dc_type, type: String
    field :dcterms_created, type: Date
    field :dcterms_medium, type: String
    field :dcterms_spatial, type: String
    field :edm_currentLocation, type: String
    field :edm_type, type: String

    belongs_to :edm_wasPresentAt, class_name: 'EDM::Event', inverse_of: :edm_wasPresentAt_for, optional: true

    has_rdf_predicate :dc_subject_agents, RDF::Vocab::DC11.subject
    has_rdf_predicate :dcterms_spatial_places, RDF::Vocab::DC.spatial

    class << self
      def dc_language_enum
        I18nData.languages(I18n.locale).map { |code, name| [name, code.downcase] }
      end

      def edm_type_enum
        %w(IMAGE SOUND TEXT VIDEO 3D)
      end
    end

    delegate :edm_type_enum, :dc_language_enum, to: :class
    delegate :edm_dataProvider, :edm_provider, to: :ore_aggregation, allow_nil: true

    before_validation :derive_edm_type_from_edm_isShownBy, unless: :edm_type?

    validates :dc_description, presence: true, unless: :dc_title?
    validates :dc_language, inclusion: { in: dc_language_enum.map(&:last) }, allow_blank: true
    validates :dc_title, presence: true, unless: :dc_description?
    validates :edm_type, inclusion: { in: edm_type_enum }, presence: true

    accepts_nested_attributes_for :dc_subject_agents, :dc_contributor, :dcterms_spatial_places,
      allow_destroy: true

    rails_admin do
      visible false
      object_label_method { :dc_title }

      list do
        field :edm_type
        field :dc_title
        field :dc_creator
        field :dc_contributor
      end

      edit do
        field :edm_type, :enum
        field :dc_title
        field :dc_description, :text
        field :dc_creator
        field :dc_contributor
        field :dc_identifier
        field :dc_date
        field :dc_relation
        field :dcterms_created
        field :dc_language, :enum
        field :dc_subject
        field :dc_subject_agents
        field :dc_type
        field :dcterms_medium
        field :dcterms_spatial_places
        field :edm_currentLocation
        field :edm_wasPresentAt
      end
    end

    def derive_edm_type_from_edm_isShownBy
      self.edm_type = ore_aggregation&.edm_isShownBy&.edm_type_from_media_content_type
    end
  end
end
