# frozen_string_literal: true

FactoryBot.define do
  sequence(:external_uid) { |n| "uid_#{n}" }
  sequence(:screen_name) { |n| "screen_name_#{n}" }
  sequence(:name) { |n| "John Doe#{n}" }
  sequence(:email) { |n| "user#{n}@example.org" }
end
