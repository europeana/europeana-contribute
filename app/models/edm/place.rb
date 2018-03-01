# frozen_string_literal: true

module EDM
  class Place
    include Mongoid::Document
    include Mongoid::Timestamps
    include Mongoid::Uuid
    include AutocompletableModel
    include Blankness::Mongoid
    include RDF::Graphable

    has_one :edm_happenedAt_for,
            class_name: 'EDM::Event', inverse_of: :edm_happenedAt

    field :owl_sameAs, type: String
    field :rdf_about, type: String
    field :skos_altLabel, type: String
    field :skos_prefLabel, type: String
    field :skos_note, type: String
    field :wgs84_pos_lat, type: Float
    field :wgs84_pos_long, type: Float

    index(rdf_about: 1)

    validates :rdf_about, uniqueness: true
    validates :rdf_about, format: { with: %r{\Ahttps?://} }

    is_rdf_literal_if_blank_without RDF::Vocab::SKOS.prefLabel

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

    def rdf_uri
      rdf_about? ? RDF::URI.new(rdf_about) : super
    end
  end
end
