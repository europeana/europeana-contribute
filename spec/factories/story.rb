# frozen_string_literal: true

FactoryBot.define do
  factory :story, class: Story do
    ore_aggregation { build(:ore_aggregation) }
  end
end
