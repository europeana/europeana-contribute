# frozen_string_literal: true

FactoryBot.define do
  factory :user, class: User do
    email Forgery::Internet.email_address
    password 'pwaSBtAnSHRJ'
    password_confirmation 'pwaSBtAnSHRJ'
    role :admin
  end
end
