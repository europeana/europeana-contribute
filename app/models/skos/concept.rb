# frozen_string_literal: true

module SKOS
  class Concept
    include Mongoid::Document

    rails_admin do
      visible false
    end
  end
end
