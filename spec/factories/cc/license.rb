# frozen_string_literal: true

FactoryBot.define do
  factory :cc_license, class: CC::License do
    sequence :rdf_about do |n|
     "http://www.example.com/license/#{n}"
    end
  end
end
