# frozen_string_literal: true

FactoryBot.define do
  factory :campaign, class: Campaign do
    sequence(:dc_identifier) { |n| "campaign-#{n}" }
  end
end
