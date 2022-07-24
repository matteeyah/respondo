# frozen_string_literal: true

FactoryBot.define do
  factory :brand_account do
    external_uid { generate(:external_uid) }
    provider { 'twitter' }
    screen_name { Faker::Internet.username }

    brand
  end
end
