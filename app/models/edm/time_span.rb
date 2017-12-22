# frozen_string_literal: true

module EDM
  class TimeSpan
    include Mongoid::Document
    include RDFModel
    include RemoveBlankAttributes

    embedded_in :edm_occurredAt_for, class_name: 'EDM::Event', inverse_of: :edm_occurredAt

    field :edm_begin, type: Date
    field :edm_end, type: Date
    field :skos_altLabel, localize: true
    field :skos_prefLabel, localize: true
    field :skos_note, localize: true

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
