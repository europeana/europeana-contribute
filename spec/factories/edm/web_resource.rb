# frozen_string_literal: true

FactoryBot.define do
  factory :edm_web_resource, class: EDM::WebResource do
    media { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'support', 'media', 'image.jpg'), 'image/jpeg') }
  end
end
