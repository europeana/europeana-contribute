# frozen_string_literal: true

FactoryBot.define do
  factory :ore_aggregation, class: ORE::Aggregation do
    edm_aggregatedCHO { build(:edm_provided_cho) }
    edm_dataProvider { Rails.configuration.x.edm.data_provider }
    edm_isShownBy { build(:edm_web_resource) }
    edm_provider { Rails.configuration.x.edm.provider }
    edm_rights { build(:cc_license) }
    edm_ugc 'true'
  end
end
