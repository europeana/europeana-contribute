# frozen_string_literal: true

# @see https://github.com/europeana/corelib/wiki/EDMObjectTemplatesProviders#edmProvidedCHO
# TODO: EDM validations
#       - one of dc:subject, dc:type, dcterms:spatial or dcterms:temporal is mandatory
#       - either dc:description or dc:title is mandatory
module EDM
  class ProvidedCHO
    include Mongoid::Document
    include RDFModel
    include RemoveBlankAttributes

    embedded_in :ore_aggregation, class_name: 'ORE::Aggregation', inverse_of: :edm_aggregatedCHO

    embeds_one :dc_creator, class_name: 'EDM::Agent', inverse_of: :dc_creator_for
    embeds_one :dc_contributor, class_name: 'EDM::Agent', inverse_of: :dc_contributor_for
    # embeds_many :dc_subjects, class_name: 'SKOS::Concept'

    field :dc_date, type: Date
    field :dc_description, type: String
    field :dc_language, type: String
    field :dc_relation, type: String
    field :dc_subject, type: String
    field :dc_title, type: String
    field :dc_type, type: String
    field :dcterms_created, type: Date
    field :dcterms_medium, type: String
    field :edm_currentLocation, type: String
    field :edm_type, type: String

    class << self
      def dc_language_enum
        Iso639::LanguagesByAlpha2.map { |code, lang| [lang.name, code.to_s] }
      end

      def edm_type_enum
        %w(IMAGE SOUND TEXT VIDEO 3D)
      end
    end

    delegate :edm_type_enum, :dc_language_enum, to: :class

    validates :dc_description, presence: true, unless: :dc_title?
    validates :dc_title, presence: true, unless: :dc_description?
    validates :edm_type, inclusion: { in: edm_type_enum }, presence: true
    validates :dc_language, inclusion: { in: dc_language_enum.map(&:last) }

    accepts_nested_attributes_for :dc_creator, :dc_contributor, reject_if: :all_blank

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
        field :dc_title, :string
        field :dc_description, :text
        field :dc_creator
        field :dc_contributor
        field :dc_date
        field :dc_relation
        field :dcterms_created
        field :dc_language, :enum
        field :dc_subject
        field :dc_type
        field :dcterms_medium
        field :edm_currentLocation
      end
    end
  end
end
