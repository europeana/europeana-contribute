# frozen_string_literal: true

module SKOS
  class Concept
    include Mongoid::Document
    include Mongoid::Timestamps
    include Mongoid::Uuid

    field :skos_altLabel
    field :skos_prefLabel
    field :skos_note

    rails_admin do
      visible false
    end
  end
end
