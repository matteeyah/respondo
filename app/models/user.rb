# frozen_string_literal: true

class User < ApplicationRecord
  validates :name, presence: { allow_blank: false }

  belongs_to :organization, optional: true

  has_many :accounts, class_name: "UserAccount", inverse_of: :user, dependent: :destroy
  has_many :internal_notes, inverse_of: :creator, foreign_key: :creator_id, dependent: :restrict_with_error
  has_many :assignments, dependent: :destroy

  def account_for_provider?(provider)
    accounts.exists?(provider:)
  end
end
