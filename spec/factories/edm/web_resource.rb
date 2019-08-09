# frozen_string_literal: true

FactoryBot.define do
  factory :edm_web_resource, class: EDM::WebResource do
    edm_rights { build(:cc_license) }
    trait :image_media do
      media { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'support', 'media', 'image.jpg'), 'image/jpeg') }
    end
    trait :audio_media do
      media { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'support', 'media', 'audio.mp3'), 'audio/mpeg') }
    end
    trait :published do
      aasm_state 'published'
    end
  end
end
