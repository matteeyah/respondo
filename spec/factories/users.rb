# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    external_uid { generate(:external_uid) }
    name { Faker::Name.name }
    email { Faker::Internet.safe_email }
  end
end
