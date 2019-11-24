# frozen_string_literal: true

FactoryBot.define do
  factory :user_account do
    external_uid { generate(:external_uid) }
    provider { 'google_oauth2' }

    user
  end
end
