# frozen_string_literal: true

FactoryBot.define do
  factory :internal_ticket do
    source { FactoryBot.build(:brand_account, provider:, brand:) }

    transient do
      external_uid { generate(:external_uid) }
      status { :open }
      content { Faker::Lorem.sentence }
      provider { 'twitter' }
      parent { nil }
      author { FactoryBot.build(:author) }
      brand { FactoryBot.build(:brand) }
    end

    base_ticket do
      Ticket.new(external_uid:, status:, content:, parent:, author:, brand:)
    end

    after(:build) do |internal_ticket|
      internal_ticket.base_ticket.author.provider = internal_ticket.base_ticket.provider
    end
  end
end
