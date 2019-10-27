# typed: true
# frozen_string_literal: true

class User < ApplicationRecord
  validates :name, presence: true, allow_blank: false

  belongs_to :brand, optional: true
  has_many :accounts, dependent: :destroy

  Account.providers.each do |provider, value|
    has_one :"#{provider}_account", -> { where(provider: value) }, class_name: 'Account', inverse_of: :user
  end

  def account_for_provider?(provider)
    accounts.exists?(provider: provider)
  end

  def client_for_provider(provider)
    accounts.find_by(provider: provider)&.client
  end
end
