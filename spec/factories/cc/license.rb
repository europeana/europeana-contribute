# frozen_string_literal: true

FactoryBot.define do
  factory :cc_license, class: CC::License do
    rdf_about 'http://www.example.com/license/'
  end
end
