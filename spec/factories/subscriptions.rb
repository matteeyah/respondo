# frozen_string_literal: true

FactoryBot.define do
  factory :subscription do
    external_uid { generate(:external_uid) }
    status { 'active' }
    email { Faker::Internet.email }
    cancel_url { Faker::Internet.url(host: 'example.com') }
    update_url { Faker::Internet.url(host: 'example.com') }

    brand
  end
end
