# typed: false
# frozen_string_literal: true

FactoryBot.define do
  sequence(:external_uid) { |n| "uid_#{n}" }
end
