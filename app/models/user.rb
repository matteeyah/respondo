# frozen_string_literal: true

class User < ApplicationRecord
  validates :name, presence: { allow_blank: false }

  belongs_to :brand, optional: true
  has_many :user_accounts, dependent: :destroy
  has_many :personal_access_tokens, dependent: :destroy
  has_many :comments, dependent: :restrict_with_error

  UserAccount.providers.each do |provider, value|
    has_one :"#{provider}_account", -> { where(provider: value) }, class_name: 'UserAccount', inverse_of: :user
  end

  def account_for_provider?(provider)
    user_accounts.exists?(provider: provider)
  end

  def client_for_provider(provider)
    user_accounts.find_by(provider: provider)&.client
  end
end
