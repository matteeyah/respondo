# frozen_string_literal: true

FactoryBot.define do
  factory :assignment do
    transient do
      brand { create(:brand) }
    end

    ticket { build(:internal_ticket, brand:).base_ticket }
    user { build(:user, brand:) }
  end
end
