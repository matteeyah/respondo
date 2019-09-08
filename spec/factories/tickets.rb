# frozen_string_literal: true

FactoryBot.define do
  factory :ticket do
    external_uid { generate(:external_uid) }
    content { 'Sample content.' }

    brand
    author
  end
end
