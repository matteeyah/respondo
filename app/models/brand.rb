# frozen_string_literal: true

class Brand < ApplicationRecord
  validates :screen_name, presence: { allow_blank: false }

  has_many :brand_accounts, dependent: :destroy
  has_many :users, dependent: :nullify
  has_many :tickets, dependent: :restrict_with_error

  BrandAccount.providers.each do |provider, value|
    has_one :"#{provider}_account", -> { where(provider: value) }, class_name: 'BrandAccount', inverse_of: :brand
  end

  class << self
    def search(query)
      where(arel_table[:screen_name].matches("%#{query}%"))
    end
  end

  def account_for_provider?(provider)
    brand_accounts.exists?(provider: provider)
  end

  def client_for_provider(provider)
    brand_accounts.find_by(provider: provider)&.client
  end
end
