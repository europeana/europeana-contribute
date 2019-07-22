# frozen_string_literal: true

FactoryBot.define do
  factory :campaign, class: Campaign do
    sequence(:dc_identifier) { |n| "campaign-#{n}" }
    trait :europe_at_work do
      dc_identifier 'europe-at-work'
    end
    trait :migration do
      dc_identifier 'migration'
    end
  end
end
