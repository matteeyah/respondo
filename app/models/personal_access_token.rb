# frozen_string_literal: true

class PersonalAccessToken < ApplicationRecord
  has_secure_password :token

  validates :name, presence: { allow_blank: false }, uniqueness: true

  belongs_to :user
end
