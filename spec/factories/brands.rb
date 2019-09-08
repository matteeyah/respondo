# frozen_string_literal: true

FactoryBot.define do
  factory :brand do
    external_uid { generate(:external_uid) }
    screen_name { generate(:screen_name) }
  end
end
