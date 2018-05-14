# frozen_string_literal: true

module CC
  class License
    include Mongoid::Document
    include Mongoid::Timestamps

    has_many :edm_rights_for_edm_web_resources,
             class_name: 'EDM::WebResource', inverse_of: :edm_rights,
             dependent: :restrict
    has_many :edm_rights_for_ore_aggregations,
             class_name: 'ORE::Aggregation', inverse_of: :edm_rights,
             dependent: :restrict

    field :rdf_about, type: String

    index({ rdf_about: 1 }, unique: true)

    validates :rdf_about, presence: true, uniqueness: true

    def rdf_uri
      RDF::URI.new(rdf_about)
    end
  end
end
