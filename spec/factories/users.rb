# typed: false
# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    name { Faker::Name.name }

    trait :with_account do
      after(:create) do |user|
        create(:account, user: user)
      end
    end
  end
end
