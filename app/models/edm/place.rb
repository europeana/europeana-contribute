# frozen_string_literal: true

module EDM
  class Place
    include Mongoid::Document
    include RDFModel
    include RemoveBlankAttributes

    field :wgs84_pos_lat, type: Float
    field :wgs84_pos_long, type: Float
    field :skos_prefLabel, type: String
    field :skos_altLabel, type: String
    field :owl_sameAs, type: String

    has_rdf_type RDF::Vocab::EDM.WebResource

    rails_admin do
      visible false

      object_label_method { :skos_prefLabel }

      field :skos_prefLabel
      field :wgs84_pos_lat, :string
      field :wgs84_pos_long, :string
    end

    def blank?
      attributes.except('_id').values.all?(&:blank?)
    end
  end
end
