# frozen_string_literal: true

FactoryBot.define do
  factory :account do
    external_uid { generate(:external_uid) }
    provider { 'twitter' }

    user
  end
end
