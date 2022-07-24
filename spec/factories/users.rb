# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    name { Faker::Name.name }

    trait :with_account do
      after(:create) do |user|
        create(:user_account, user:, provider: 'google_oauth2')
      end
    end
  end
end
