# frozen_string_literal: true

FactoryBot.define do
  factory :ticket do
    external_uid { generate(:external_uid) }
    content { Faker::Lorem.sentence }

    brand
    author
  end
end
