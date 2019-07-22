# frozen_string_literal: true

# Contributions are made within the context of a specific campaign, often
# themed to a subject area such as Migration or World War I.
#
# @example
#   photography_campaign = Campaign.create(dc_identifier: 'photography')
#   photography_contribution = Contribution.new(campaign: photography_campaign)
class Campaign
  include Mongoid::Document
  include Mongoid::Timestamps

  # @!attribute contributions
  #   The contributions made within this this campaign.
  #   @return [Mongoid::Relations::Targets::Enumerable<Contribution>]
  has_many :contributions, class_name: 'Contribution', inverse_of: :campaign,
                           dependent: :restrict

  # @!attribute dc_identifier
  #   The dc:identifier of this campaign. Required, and must be unique.
  #   @return [String]
  field :dc_identifier, type: String

  # @!attribute dc_subject
  #   A dc:subject for this campaign.
  #   @return [String]
  field :dc_subject, type: String

  validates :dc_identifier, uniqueness: true, presence: true

  # Constructs an RDF URI from app base URL, +"/campaigns/"+ and +#dc_identifier+
  #
  # @return [RDF::URI] RDF URI for this campaign
  #
  # @example
  #   Rails.configuration.x.base_url = 'http://example.org'
  #   campaign = Campaign.new(dc_identifier: 'folk-music')
  #   campaign.rdf_uri #=> #<RDF::URI:0x2aac366eaf5c URI:http://example.org/campaigns/folk-music>
  def rdf_uri
    RDF::URI.new("#{Rails.configuration.x.base_url}/campaigns/#{dc_identifier}")
  end

  # OAI-PMH set for this campaign
  #
  # Set spec is taken from the campaign's +dc_identifier+.
  #
  # @return [OAI::Set]
  def oai_pmh_set
    OAI::Set.new(name: "Europeana Contribute campaign: #{dc_identifier}",
                 spec: dc_identifier)
  end

  def to_param
    dc_identifier.underscore
  end
end
