# frozen_string_literal: true

FactoryBot.define do
  factory :brand_account do
    external_uid { generate(:external_uid) }
    provider { BrandAccount.providers.keys.sample }
    screen_name { Faker::Internet.username }

    brand
  end
end
