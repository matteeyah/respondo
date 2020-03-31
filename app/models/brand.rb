# frozen_string_literal: true

class Brand < ApplicationRecord
  include HasAccounts

  validates :screen_name, presence: { allow_blank: false }
  validates :domain, format: { with: /\A[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}\z/ }, allow_nil: true

  has_many :accounts, class_name: 'BrandAccount', inverse_of: :brand, dependent: :destroy
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
end
