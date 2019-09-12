# frozen_string_literal: true

class User < ApplicationRecord
  validates :external_uid, presence: true, allow_blank: false
  validates :name, presence: true, allow_blank: false
  validates :email, presence: true, allow_blank: false

  belongs_to :brand, optional: true

  scope :not_in_brand, ->(brand_id) { where.not(brand_id: brand_id).or(where(brand_id: nil)) }

  class << self
    def from_omniauth(auth)
      find_or_create_by(external_uid: auth.uid) do |user|
        user.email = auth.info.email
        user.name = auth.info.name
      end
    end
  end
end
