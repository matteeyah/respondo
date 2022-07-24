# frozen_string_literal: true

FactoryBot.define do
  factory :brand do
    screen_name { Faker::Internet.domain_word }
  end

  trait :with_account do
    after(:create) do |brand|
      create(:brand_account, brand:, provider: 'twitter')
    end
  end
end
