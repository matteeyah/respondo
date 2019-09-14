# frozen_string_literal: true

class User < ApplicationRecord
  validates :name, presence: true, allow_blank: false

  belongs_to :brand, optional: true
  has_many :accounts

  has_one :twitter_account, -> { where(provider: 'twitter') }, class_name: 'Account'
  has_one :google_oauth2_account, -> { where(provider: 'google_oauth2') }, class_name: 'Account'

  scope :not_in_brand, ->(brand_id) { where.not(brand_id: brand_id).or(where(brand_id: nil)) }

  def client_for(provider)
    accounts.find_by(provider)&.client
  end
end
