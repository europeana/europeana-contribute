# frozen_string_literal: true

FactoryBot.define do
  factory :ore_aggregation, class: ORE::Aggregation do
    edm_ugc 'true'
    edm_dataProvider Forgery::Name.company_name
    edm_provider Forgery::Name.company_name
    edm_isShownBy { build(:edm_web_resource) }
    edm_aggregatedCHO { build(:edm_provided_cho) }
    edm_rights { build(:cc_license) }
    trait :published do
      edm_aggregatedCHO { build(:edm_provided_cho, :published) }
    end
  end
end
