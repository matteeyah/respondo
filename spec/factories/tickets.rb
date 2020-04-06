# frozen_string_literal: true

FactoryBot.define do
  factory :ticket do
    external_uid { generate(:external_uid) }
    content { Faker::Lorem.sentence }
    provider { 'twitter' }

    brand
    author

    after(:build) do |ticket|
      ticket.author.provider = ticket.provider

      ticket.response_url = 'https://response_url.com' if ticket.provider == 'external'
    end
  end
end
