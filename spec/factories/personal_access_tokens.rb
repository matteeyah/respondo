# frozen_string_literal: true

FactoryBot.define do
  factory :personal_access_token do
    name { generate(:token_name) }
    token { SecureRandom.base64(10) }

    user
  end
end
