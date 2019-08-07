# frozen_string_literal: true

FactoryBot.define do
  factory :edm_provided_cho, class: EDM::ProvidedCHO do
    dc_description { [Forgery::LoremIpsum.paragraphs(5)] }
    sequence(:dc_title) { |n| ["DC Title #{n}"] }
    edm_type 'IMAGE'
    dc_language ['en']
    trait :published do
      aasm_state 'published'
      dc_subject ['Matter']
    end
  end
end
