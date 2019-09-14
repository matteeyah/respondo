# frozen_string_literal: true

class User < ApplicationRecord
  validates :name, presence: true, allow_blank: false

  belongs_to :brand, optional: true
  has_many :accounts

  scope :not_in_brand, ->(brand_id) { where.not(brand_id: brand_id).or(where(brand_id: nil)) }
end
