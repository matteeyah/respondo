# frozen_string_literal: true

FactoryBot.define do
  factory :brand do
    external_uid { generate(:external_uid) }
    screen_name { Faker::Internet.domain_word }
  end
end
