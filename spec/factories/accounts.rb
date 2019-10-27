# typed: false
# frozen_string_literal: true

FactoryBot.define do
  factory :account do
    external_uid { generate(:external_uid) }
    provider { 'google_oauth2' }

    user
  end
end
