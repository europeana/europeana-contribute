# frozen_string_literal: true

FactoryBot.define do
  factory :story, class: Story do
    ore_aggregation { build(:ore_aggregation) }
    trait :published do
      aasm_state 'published'
      ore_aggregation { build(:ore_aggregation, :published) }
    end
  end
end
