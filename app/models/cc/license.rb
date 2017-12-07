# frozen_string_literal: true

module CC
  class License
    include Mongoid::Document

    has_many :ore_aggregations, class_name: 'ORE::Aggregation', inverse_of: :edm_rights

    field :rdf_about, type: String
    index({ rdf_about: 1 }, unique: true)

    validates :rdf_about, presence: true, uniqueness: true

    rails_admin do
      object_label_method { :rdf_about }
      field :rdf_about, :string
      list do
        sort_by :rdf_about
      end
    end

    def rdf_uri
      RDF::URI.new(rdf_about)
    end
  end
end
