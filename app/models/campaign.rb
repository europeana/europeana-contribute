# frozen_string_literal: true

class Campaign
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :contributions, class_name: 'Contribution', inverse_of: :campaign,
                           dependent: :restrict

  field :dc_identifier, type: String
  field :dc_subject, type: String

  validates :dc_identifier, uniqueness: true, presence: true

  def rdf_uri
    RDF::URI.new("#{Rails.configuration.x.base_url}/campaigns/#{dc_identifier}")
  end
end
