# frozen_string_literal: true

module SKOS
  class Concept
    include Mongoid::Document

    field :skos_altLabel, localize: true
    field :skos_prefLabel, localize: true
    field :skos_note, localize: true

    rails_admin do
      visible false

      object_label_method { :skos_prefLabel }

      field :skos_prefLabel
      field :skos_note
    end
  end
end
