# frozen_string_literal: true

module EDM
  class Place
    include Mongoid::Document
    include AutocompletableModel
    include RDFModel
    include RemoveBlankAttributes

    embedded_in :dcterms_spatial_places_for, class_name: 'EDM::ProvidedCHO', inverse_of: :dcterms_spatial_places
    embedded_in :edm_happenedAt_for, class_name: 'EDM::Event', inverse_of: :edm_happenedAt

    field :wgs84_pos_lat, type: Float
    field :wgs84_pos_long, type: Float
    field :skos_altLabel, localize: true
    field :skos_prefLabel, localize: true
    field :skos_note, localize: true
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
