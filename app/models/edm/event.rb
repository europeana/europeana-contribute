# frozen_string_literal: true

module EDM
  class Event
    include Mongoid::Document
    include Mongoid::Timestamps
    include RDFModel
    include RemoveBlankAttributes

    # has_many :edm_wasPresentAt_for, class_name: 'EDM::ProvidedCHO', inverse_of: :edm_wasPresentAt
    embeds_one :edm_happenedAt, class_name: 'EDM::Place', inverse_of: :edm_happenedAt_for
    embeds_one :edm_occurredAt, class_name: 'EDM::TimeSpan', inverse_of: :edm_occurredAt_for

    field :dc_identifier, type: String
    field :edm_isRelatedTo, type: String
    field :skos_altLabel, localize: true
    field :skos_prefLabel, localize: true
    field :skos_note, localize: true

    accepts_nested_attributes_for :edm_happenedAt, :edm_occurredAt, reject_if: :all_blank

    rails_admin do
      field :dc_identifier, :string
      field :skos_prefLabel
      field :edm_isRelatedTo, :string
      field :skos_note
      field :edm_happenedAt
      field :edm_occurredAt
    end

    def name
      candidates = [skos_prefLabel, edm_happenedAt&.name, edm_occurredAt&.name].compact
      candidates.present? ? candidates.join(', ') : id.to_s
    end
  end
end
