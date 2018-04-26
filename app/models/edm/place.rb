# frozen_string_literal: true

module EDM
  class Place
    include Mongoid::Document
    include Mongoid::Timestamps
    include Mongoid::Uuid
    include ArrayOfAttributeValidation
    include AutocompletableModel
    include Blankness::Mongoid::Attributes
    include Blankness::Mongoid::Relations
    include RDF::Graphable
    include RDF::Graphable::Literalisation

    has_one :edm_happenedAt_for,
            class_name: 'EDM::Event', inverse_of: :edm_happenedAt

    field :owl_sameAs, type: ArrayOf.type(String), default: []
    field :skos_altLabel, type: ArrayOf.type(String), default: []
    field :skos_prefLabel, type: String
    field :skos_note, type: ArrayOf.type(String), default: []
    field :wgs84_pos_lat, type: Float
    field :wgs84_pos_long, type: Float

    graphs_as_literal RDF::Vocab::SKOS.prefLabel

    rails_admin do
      visible false

      field :owl_sameAs
      field :skos_altLabel
      field :skos_prefLabel
      field :skos_note
      field :wgs84_pos_lat, :string
      field :wgs84_pos_long, :string
    end

    def name
      skos_prefLabel
    end
  end
end
