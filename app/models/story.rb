# frozen_string_literal: true

##
# Primary container for the data associated with a contributed story.
class Story
  include Mongoid::Document
  include Mongoid::Timestamps
  include AASM
  include RDF::Dumpable

  belongs_to :ore_aggregation, class_name: 'ORE::Aggregation', inverse_of: :story,
                               autobuild: true, index: true, dependent: :destroy,
                               touch: true
  belongs_to :created_by, class_name: 'User', optional: true, inverse_of: :stories,
                          index: true

  field :aasm_state

  index(created_at: 1)
  index(updated_at: 1)
  index(aasm_state: 1)

  accepts_nested_attributes_for :ore_aggregation

  validates_associated :ore_aggregation

  delegate :to_rdf, to: :ore_aggregation

  aasm do
    state :draft, initial: true
    state :published, :deleted

    event :publish do
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
    list do
      field :ore_aggregation
      field :aasm_state
      field :created_at
      field :created_by
      field :updated_at
    end

    show do
      field :ore_aggregation
      field :aasm_state
      field :created_at
      field :created_by
      field :updated_at
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
    Europeana::Stories::OAI::Model.sets.select do |set|
      set.name == ore_aggregation.edm_provider
    end
  end

  def has_media?
    ore_aggregation.edm_web_resources.any?(&:media?)
  end
end
