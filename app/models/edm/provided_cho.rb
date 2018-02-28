# frozen_string_literal: true

# @see https://github.com/europeana/corelib/wiki/EDMObjectTemplatesProviders#edmProvidedCHO
module EDM
  class ProvidedCHO
    include Mongoid::Document
    include Mongoid::Timestamps
    include AutocompletableModel
    include Blankness::Mongoid
    include CampaignValidatableModel
    include RDFModel

    field :dc_creator, type: String
    field :dc_date, type: Date
    field :dc_description, type: String
    field :dc_identifier, type: String
    field :dc_language, type: String
    field :dc_relation, type: String
    field :dc_subject, type: String
    field :dc_title, type: String
    field :dc_type, type: String
    field :dcterms_created, type: Date
    field :dcterms_medium, type: String
    field :dcterms_spatial, type: Array, default: []
    field :dcterms_temporal, type: String
    field :edm_currentLocation, type: String
    field :edm_type, type: String

    belongs_to :dc_contributor_agent,
               class_name: 'EDM::Agent', inverse_of: :dc_contributor_agent_for,
               optional: true, dependent: :destroy, touch: true
    belongs_to :edm_wasPresentAt,
               class_name: 'EDM::Event', inverse_of: :edm_wasPresentAt_for,
               optional: true, index: true
    has_and_belongs_to_many :dc_subject_agents,
                            class_name: 'EDM::Agent', inverse_of: :dc_subject_agent_for,
                            dependent: :destroy
    has_one :edm_aggregatedCHO_for,
            class_name: 'ORE::Aggregation', inverse_of: :edm_aggregatedCHO

    accepts_nested_attributes_for :dc_subject_agents, :dc_contributor_agent,
                                  allow_destroy: true

    rejects_blank :dc_contributor_agent, :dc_subject_agents
    is_present_unless_blank :dc_contributor_agent, :dc_subject_agents, :edm_wasPresentAt

    has_rdf_predicate :dc_contributor_agent, RDF::Vocab::DC11.contributor
    has_rdf_predicate :dc_subject_agents, RDF::Vocab::DC11.subject

    class << self
      def dc_language_enum
        I18nData.languages(I18n.locale).map { |code, name| [name, code.downcase] }
      end

      def edm_type_enum
        %w(IMAGE SOUND TEXT VIDEO 3D)
      end
    end

    delegate :edm_type_enum, :dc_language_enum, to: :class
    delegate :edm_dataProvider, :edm_provider, :draft?, :published?, :deleted?,
             to: :edm_aggregatedCHO_for, allow_nil: true

    before_validation :derive_edm_type_from_edm_isShownBy, unless: :edm_type?

    validates :dc_language, inclusion: { in: dc_language_enum.map(&:last) }, allow_blank: true
    validates :edm_type, inclusion: { in: edm_type_enum }, presence: true, if: :published?
    validates_associated :dc_contributor_agent, :dc_subject_agents
    validates_with PresenceOfAnyValidator,
                   of: %i(dc_subject dc_subject_agents dc_type dcterms_spatial dcterms_temporal),
                   if: :published?
    validates_with PresenceOfAnyValidator, of: %i(dc_title dc_description), if: :published?

    rails_admin do
      visible false
      object_label_method { :dc_title }

      list do
        field :edm_type
        field :dc_title
        field :dc_creator
        field :dc_contributor_agent
      end

      edit do
        field :edm_type, :enum
        field :dc_title
        field :dc_description, :text
        field :dc_creator
        field :dc_contributor_agent
        field :dc_identifier
        field :dc_date
        field :dc_relation
        field :dcterms_created
        field :dc_language, :enum
        field :dc_subject
        field :dc_subject_agents
        field :dc_type
        field :dcterms_medium
        field :edm_currentLocation
        field :edm_wasPresentAt do
          inline_add false
          inline_edit false
        end
      end
    end

    def derive_edm_type_from_edm_isShownBy
      self.edm_type = edm_aggregatedCHO_for&.edm_isShownBy&.edm_type_from_media_content_type
    end
  end
end
