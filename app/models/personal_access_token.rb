# frozen_string_literal: true

class PersonalAccessToken < ApplicationRecord
  has_secure_password :token

  validates :name, presence: { allow_blank: false }, uniqueness: { scope: :user_id }

  belongs_to :user
end
