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

  field :aasm_state
  field :age_confirm, type: Boolean, default: false
  field :content_policy_accept, type: Boolean, default: false
  field :display_and_takedown_accept, type: Boolean, default: false
  field :first_published_at, type: DateTime
  field :guardian_consent, type: Boolean, default: false

  index(aasm_state: 1)
  index(created_at: 1)
  index(first_published_at: 1)
  index(updated_at: 1)

  accepts_nested_attributes_for :ore_aggregation

  validates_associated :ore_aggregation
  validates :age_confirm, acceptance: { accept: [true, 1], message: I18n.t('global.forms.validation-errors.user-age') }, unless: :guardian_consent
  validates :guardian_consent, acceptance: { accept: [true, 1], message: I18n.t('global.forms.validation-errors.user-age-consent') }, unless: :age_confirm
  validate :age_and_consent_exclusivity
  validates :content_policy_accept, acceptance: { accept: [true, 1], message: I18n.t('contribute.campaigns.migration.form.validation.content-policy-accept') }
  validates :display_and_takedown_accept, acceptance: { accept: [true, 1], message: I18n.t('contribute.campaigns.migration.form.validation.display-and-takedown-accept') }

  delegate :to_rdf, to: :ore_aggregation

  aasm do
    state :draft, initial: true
    state :published, :deleted

    event :publish do
      before do
        self.first_published_at = Time.zone.now if self.first_published_at.nil?
      end
      transitions from: :draft, to: :published
    end

    event :unpublish do
      transitions from: :published, to: :draft
    end

    event :wipe do # named :wipe and not :delete because Mongoid::Document brings #delete
      transitions from: :draft, to: :deleted
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

  # OAI-PMH set(s) this aggregation is in
  def sets
    Europeana::Contribute::OAI::Model.sets.select do |set|
      set.name == ore_aggregation.edm_provider
    end
  end

  # Does this web resource have media uploaded?
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

  def to_param
    ore_aggregation.edm_aggregatedCHO.uuid
  end
end
