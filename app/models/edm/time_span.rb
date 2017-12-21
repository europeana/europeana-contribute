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
      object_label_method { :skos_prefLabel }
      field :skos_prefLabel
      field :edm_begin
      field :edm_end
      field :skos_note
    end
  end
end
