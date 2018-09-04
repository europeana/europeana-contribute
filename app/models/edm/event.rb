# frozen_string_literal: true

module EDM
  class Event
    include Mongoid::Document
    include Mongoid::Timestamps
    include Mongoid::Uuid
    include ArrayOfAttributeValidation
    include Blankness::Mongoid::Attributes
    include Blankness::Mongoid::Relations
    include RDF::Graphable

    field :dc_identifier, type: ArrayOf.type(String), default: []
    field :edm_isRelatedTo, type: ArrayOf.type(String), default: []
    field :skos_altLabel, type: ArrayOf.type(String), default: []
    field :skos_prefLabel, type: String
    field :skos_note, type: ArrayOf.type(String), default: []

    belongs_to :edm_happenedAt,
               class_name: 'EDM::Place', inverse_of: :edm_happenedAt_for,
               optional: true, dependent: :destroy
    belongs_to :edm_occurredAt,
               class_name: 'EDM::TimeSpan', inverse_of: :edm_occurredAt_for,
               optional: true, dependent: :destroy
    has_many :edm_wasPresentAt_for,
             class_name: 'EDM::ProvidedCHO', inverse_of: :edm_wasPresentAt,
             dependent: :restrict

    accepts_nested_attributes_for :edm_happenedAt, :edm_occurredAt

    rejects_blank :edm_happenedAt, :edm_occurredAt
    is_present_unless_blank :edm_happenedAt, :edm_occurredAt

    # While not a requirement of EDM, without one of these, we know little of
    # practical use about an event.
    validates_with PresenceOfAnyValidator,
                   of: %i(skos_prefLabel edm_happenedAt edm_occurredAt)

    validates_associated :edm_happenedAt, :edm_occurredAt

    def name
      candidates = [skos_prefLabel, edm_happenedAt&.name, edm_occurredAt&.name].compact
      candidates.present? ? candidates.join(', ') : id.to_s
    end

    def to_rdf
      RDF::Literal.new(name)
    end

    # Can this event be destroyed?
    #
    # If this event is an edm_wasPresentAt for any CHOs, it may not be destroyed
    def destroyable?
      edm_wasPresentAt_for.count.zero?
    end

    def to_param
      uuid
    end
  end
end
