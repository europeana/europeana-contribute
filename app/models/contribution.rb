# frozen_string_literal: true

##
# Primary container for the data associated with a contribution.
class Contribution
  include Mongoid::Document
  include Mongoid::Timestamps
  include AASM
  include ArrayOfAttributeValidation
  include RDF::Dumpable

  belongs_to :campaign, class_name: 'Campaign', inverse_of: :contributions, index: true
  belongs_to :ore_aggregation, class_name: 'ORE::Aggregation', inverse_of: :contribution,
                               autobuild: true, index: true, dependent: :destroy,
                               touch: true
  belongs_to :created_by, class_name: 'User', optional: true, inverse_of: :contributions,
                          index: true

  has_many :serialisations, class_name: 'Serialisation', inverse_of: :contribution,
                            dependent: :destroy

  field :aasm_state
  field :age_confirm, type: Boolean, default: false
  field :content_policy_accept, type: Boolean, default: false
  field :display_and_takedown_accept, type: Boolean, default: false
  field :first_published_at, type: DateTime
  field :guardian_consent, type: Boolean, default: false

  # @!attribute oai_pmh_record_id
  #   Record identifier for OAI-PMH.
  #   Duplicates the UUID of the aggregation's CHO when contribution is first
  #   published.
  #   @return [String]
  field :oai_pmh_record_id, type: String

  # @!attribute oai_pmh_resumption_token
  #   Resumption token for OAI-PMH.
  #   Concatenates ISO8601-formatted +first_published_at+, "/" and +oai_pmh_record_id+.
  #   Set when contribution is first published.
  #   @return [String]
  field :oai_pmh_resumption_token, type: String

  index(aasm_state: 1)
  index(created_at: 1)
  index(first_published_at: 1)
  index(oai_pmh_record_id: 1)
  index(oai_pmh_resumption_token: 1)
  index(updated_at: 1)

  accepts_nested_attributes_for :ore_aggregation

  validates_associated :ore_aggregation
  validates :age_confirm, acceptance: { accept: [true, 1], message: I18n.t('global.forms.validation-errors.user-age') }, unless: :guardian_consent
  validates :guardian_consent, acceptance: { accept: [true, 1], message: I18n.t('global.forms.validation-errors.user-age-consent') }, unless: :age_confirm
  validate :age_and_consent_exclusivity
  validates :content_policy_accept, acceptance: { accept: [true, 1], message: I18n.t('contribute.campaigns.migration.form.validation.content-policy-accept') }
  validates :display_and_takedown_accept, acceptance: { accept: [true, 1], message: I18n.t('contribute.campaigns.migration.form.validation.display-and-takedown-accept') }

  after_save :set_oai_pmh_fields, if: :published?
  after_save :queue_serialisation, unless: :deleted?

  aasm do
    state :draft, initial: true
    state :published, :deleted

    event :publish do
      before do
        # Convert to string, then re-parse to time to remove fractional seconds,
        # which level of granularity is not supported by OAI-PMH.
        self.first_published_at = Time.parse(Time.zone.now.iso8601) if self.first_published_at.nil?
      end
      transitions from: :draft, to: :published
    end

    event :unpublish do
      transitions from: :published, to: :draft
    end

    event :wipe do # named :wipe and not :delete because Mongoid::Document brings #delete
      transitions from: :draft, to: :deleted
      after do
        self.serialisations.destroy_all
      end
    end
  end

  rails_admin do
    visible false

    list do
      field :ore_aggregation
      field :aasm_state
      field :created_at
      field :created_by
      field :updated_at
      field :first_published_at
    end

    show do
      field :ore_aggregation
      field :aasm_state
      field :age_confirm
      field :guardian_consent
      field :content_policy_accept
      field :display_and_takedown_accept
      field :created_at
      field :created_by
      field :updated_at
      field :first_published_at
    end

    edit do
      field :ore_aggregation do
        inline_add false
      end
      field :created_at # TODO: to faciliate manual override during data migration; remove
    end
  end

  # OAI-PMH set(s) this contribution is in
  #
  # The set a contribution is in is determined by the +Campaign+ it is associated
  # with.
  #
  # While a contribution will only be associated with one campaign, an array is
  # returned as that is expected by the +OAI+ library.
  #
  # @return [Array<OAI::Set>]
  def sets
    [campaign.oai_pmh_set]
  end

  # Does this contribution have media uploaded?
  #
  # Checks against +EDM::WebResource#media_identifier+ (vs +#media?+ or +#media+)
  # as it does not make a call to the underlying storage service, which is essential
  # on views listing multiple contributions and needing a hint (but not
  # guarantee) as to which have media uploaded, without numerous storage service
  # calls being made.
  def has_media?
    ore_aggregation.edm_web_resources.any? { |wr| !wr.media_identifier.nil? }
  end

  def age_and_consent_exclusivity
    errors.add(:age_confirm, I18n.t('contribute.campaigns.migration.form.validation.age_and_consent_exclusivity')) if age_confirm? && guardian_consent?
  end

  # Derive an OAI-PMH resumption token for this contribution
  #
  # Concatenates ISO8601-formatted +first_published_at+, "/" and +oai_pmh_record_id+.
  #
  # @return [String]
  def derive_oai_pmh_resumption_token
    xml_time = first_published_at.iso8601
    xml_time.sub!(/[+-]00:00\z/, 'Z') # this should be done by +Time#iso8601+ but seems not
    xml_time + '/' + oai_pmh_record_id
  end

  # Set derived OAI-PMH fields
  #
  # It is ugly running this from an after_save callback, but it can not go into
  # the AASM event because the CHO may not be persisted yet, hence not yet have
  # a UUID.
  def set_oai_pmh_fields
    return if @setting_oai_pmh_fields
    @setting_oai_pmh_fields = true

    self.oai_pmh_record_id = ore_aggregation.edm_aggregatedCHO.uuid if self.oai_pmh_record_id.nil?
    self.oai_pmh_resumption_token = derive_oai_pmh_resumption_token if self.oai_pmh_resumption_token.nil?
    save

    @setting_oai_pmh_fields = false
  end

  def to_param
    ore_aggregation.edm_aggregatedCHO.uuid
  end

  def to_rdf
    serialised_rdfxml_graph || ore_aggregation.to_rdf
  end

  def to_rdfxml
    serialisations.rdfxml.first&.data || super
  end

  def to_jsonld
    to_serialised_rdf(:jsonld) || super
  end

  def to_turtle
    to_serialised_rdf(:turtle) || super
  end

  def to_ntriples
    to_serialised_rdf(:ntriples) || super
  end

  def to_serialised_rdf(format)
    graph = serialised_rdfxml_graph ? graph.dump(format) : nil
  end

  def serialised_rdfxml
    serialisations.rdfxml.first&.data
  end

  def serialised_rdfxml_graph
    if rdfxml = serialised_rdfxml
      RDF::Graph.new.from_rdfxml(rdfxml)
    end
  end

  def queue_serialisation
    SerialisationJob.perform_later(id.to_s)
  end
end
