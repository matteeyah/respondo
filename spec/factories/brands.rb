# frozen_string_literal: true

FactoryBot.define do
  factory :brand do
    external_uid { generate(:external_uid) }
    nickname { generate(:nickname) }
  end
end
