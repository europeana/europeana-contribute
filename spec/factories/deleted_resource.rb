# frozen_string_literal: true

FactoryBot.define do
  factory :deleted_resource, class: DeletedResource do
    resource_identifier SecureRandom.uuid
    trait :web_resource do
      resource_type 'EDM::WebResource'
    end
    trait :contribution do
      resource_type 'Contribution'
    end
  end
end
