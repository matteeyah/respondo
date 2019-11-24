# frozen_string_literal: true

FactoryBot.define do
  factory :brand_account do
    external_uid { generate(:external_uid) }
    provider { 'twitter' }

    brand
  end
end
