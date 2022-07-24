# frozen_string_literal: true

FactoryBot.define do
  factory :user_account do
    external_uid { generate(:external_uid) }
    provider { UserAccount.providers.except(:developer).keys.sample }

    user
  end
end
