# frozen_string_literal: true

FactoryBot.define do
  factory :internal_note do
    content { Faker::Lorem.sentence }

    user
    ticket
  end
end
