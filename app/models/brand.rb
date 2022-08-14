# frozen_string_literal: true

class Brand < ApplicationRecord
  validates :screen_name, presence: { allow_blank: false }
  validates :domain, format: { with: /\A[a-z0-9]+([\-.]{1}[a-z0-9]+)*\.[a-z]{2,5}\z/ }, allow_nil: true

  has_many :accounts, class_name: 'BrandAccount', inverse_of: :brand, dependent: :destroy
  has_many :users, dependent: :nullify, before_add: :increment_subscription_quantity,
                   before_remove: :decrement_subscription_quantity
  has_many :tickets, dependent: :restrict_with_error

  has_one :subscription, dependent: :restrict_with_error

  def account_for_provider?(provider)
    accounts.exists?(provider:)
  end

  private

  def increment_subscription_quantity(_)
    return unless subscription

    subscription.change_quantity(users.count + 1)
  end

  def decrement_subscription_quantity(_)
    return unless subscription

    subscription.change_quantity(users.count - 1)
  end
end
