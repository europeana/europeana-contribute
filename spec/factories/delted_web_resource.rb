# frozen_string_literal: true

FactoryBot.define do
  factory :deleted_web_resource, class: DeletedWebResource do
    uuid SecureRandom.uuid
  end
end
