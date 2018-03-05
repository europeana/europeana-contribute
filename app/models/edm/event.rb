# frozen_string_literal: true

module EDM
  class Event
    include Mongoid::Document
    include Mongoid::Timestamps
    include Mongoid::Uuid
    include ArrayOfAttributeValidation
    include Blankness::Mongoid
    include RDF::Graphable

    field :dc_identifier, type: ArrayOf.type(String), default: []
    field :edm_isRelatedTo, type: ArrayOf.type(String), default: []
    field :skos_altLabel, type: ArrayOf.type(String), default: []
    field :skos_prefLabel, type: String
    field :skos_note, type: ArrayOf.type(String), default: []

    belongs_to :edm_happenedAt,
               class_name: 'EDM::Place', inverse_of: :edm_happenedAt_for,
               optional: true, dependent: :destroy, touch: true
    belongs_to :edm_occurredAt,
               class_name: 'EDM::TimeSpan', inverse_of: :edm_occurredAt_for,
               optional: true, dependent: :destroy, touch: true
    has_many :contributions,
             class_name: 'Contribution', inverse_of: :edm_event
    has_one :edm_wasPresentAt_for,
            class_name: 'EDM::ProvidedCHO', inverse_of: :edm_wasPresentAt

    accepts_nested_attributes_for :edm_happenedAt, :edm_occurredAt

    rejects_blank :edm_happenedAt, :edm_occurredAt
    is_present_unless_blank :edm_happenedAt, :edm_occurredAt

    validates_associated :edm_happenedAt, :edm_occurredAt

    rails_admin do
      field :dc_identifier
      field :skos_prefLabel
      field :edm_isRelatedTo
      field :skos_note
      field :edm_happenedAt
      field :edm_occurredAt
    end

    def name
      candidates = [skos_prefLabel, edm_happenedAt&.name, edm_occurredAt&.name].compact
      candidates.present? ? candidates.join(', ') : id.to_s
    end
  end
end
