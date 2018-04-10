# frozen_string_literal: true

FactoryBot.define do
  factory :edm_web_resource, class: EDM::WebResource do
    media { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'support', 'media', 'image.jpg'), 'image/jpeg') }
    edm_rights { build(:cc_license) }
    trait :audio_media do
      media { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'support', 'media', 'audio.mp3'), 'audio/mp3') }
    end
  end
end
