# frozen_string_literal: true

FactoryBot.define do
  factory :account do
    external_uid { generate(:external_uid) }

    user
  end
end
