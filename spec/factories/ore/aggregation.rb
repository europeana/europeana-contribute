# frozen_string_literal: true

FactoryBot.define do
  factory :ore_aggregation, class: ORE::Aggregation do
    edm_ugc 'true'
    edm_isShownBy { build(:edm_web_resource) }
    edm_aggregatedCHO { build(:edm_provided_cho) }
    edm_rights { build(:cc_license) }
  end
end
