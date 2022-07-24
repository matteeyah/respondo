# frozen_string_literal: true

FactoryBot.define do
  factory :author do
    external_uid { generate(:external_uid) }
    username { Faker::Internet.username }
    provider { Author.providers.keys.sample }
  end
end
