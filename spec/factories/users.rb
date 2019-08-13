# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    external_uid { generate(:external_uid) }
    name { generate(:name) }
    email { generate(:email) }
  end
end
