# frozen_string_literal: true

FactoryBot.define do
  factory :external_ticket do
    response_url { 'https://response_url.com' }

    transient do
      external_uid { generate(:external_uid) }
      status { :open }
      content { Faker::Lorem.sentence }
      parent { nil }
      author { FactoryBot.build(:author) }
      brand { FactoryBot.build(:brand) }
    end

    base_ticket do
      Ticket.new(
        external_uid: external_uid, status: status, content: content, provider: 'external',
        parent: parent, author: author, brand: brand
      )
    end

    after(:build) do |external_ticket|
      external_ticket.base_ticket.author.provider = 'external'
    end
  end
end
