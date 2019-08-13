# frozen_string_literal: true

FactoryBot.define do
  sequence(:external_uid) { |n| "uid_#{n}" }
  sequence(:nickname) { |n| "company#{n}" }
  sequence(:name) { |n| "John Doe#{n}" }
  sequence(:email) { |n| "user#{n}@example.org" }
end
