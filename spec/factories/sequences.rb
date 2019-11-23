# frozen_string_literal: true

FactoryBot.define do
  sequence(:external_uid) { |n| "uid_#{n}" }
  sequence(:token_name) { |n| "PERSONAL_ACCESS_TOKEN_#{n}" }
end
