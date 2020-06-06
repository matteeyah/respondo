# frozen_string_literal: true

class User < ApplicationRecord
  include HasAccounts

  validates :name, presence: { allow_blank: false }

  belongs_to :brand, optional: true
  has_many :accounts, class_name: 'UserAccount', inverse_of: :user, dependent: :destroy
  has_many :personal_access_tokens, dependent: :destroy
  has_many :internal_notes, dependent: :restrict_with_error
end
