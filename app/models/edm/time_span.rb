# frozen_string_literal: true

module EDM
  class TimeSpan
    include Mongoid::Document
    include Mongoid::Timestamps
    include Mongoid::Uuid
    include Blankness::Mongoid
    include RDFModel

    field :edm_begin, type: Date
    field :edm_end, type: Date
    field :skos_altLabel, type: String
    field :skos_prefLabel, type: String
    field :skos_note, type: String

    has_one :edm_occurredAt_for,
            class_name: 'EDM::Event', inverse_of: :edm_occurredAt

    rails_admin do
      visible false
      field :skos_prefLabel
      field :edm_begin
      field :edm_end
      field :skos_note
    end

    def name
      name_with_begin_and_end || skos_prefLabel || id.to_s
    end

    def name_with_begin_and_end
      begin_and_end = [edm_begin, edm_end].compact.map(&:to_s).join('–')
      return nil unless begin_and_end.present?
      skos_prefLabel.present? ? "#{skos_prefLabel} (#{begin_and_end})" : begin_and_end
    end
  end
end
