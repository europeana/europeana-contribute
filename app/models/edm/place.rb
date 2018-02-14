# frozen_string_literal: true

module EDM
  class Place
    include Mongoid::Document
    include Mongoid::Timestamps
    include Mongoid::Uuid
    include AutocompletableModel
    include Blankness::Mongoid
    include RDF::Graphable

    has_one :dcterms_spatial_place_for,
            class_name: 'EDM::ProvidedCHO', inverse_of: :dcterms_spatial_places
    has_one :edm_happenedAt_for,
            class_name: 'EDM::Event', inverse_of: :edm_happenedAt

    field :wgs84_pos_lat, type: Float
    field :wgs84_pos_long, type: Float
    field :skos_altLabel, type: String
    field :skos_prefLabel, type: String
    field :skos_note, type: String
    field :owl_sameAs, type: String

    rails_admin do
      visible false

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
