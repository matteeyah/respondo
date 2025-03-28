# frozen_string_literal: true

class Organization < ApplicationRecord
  validates :screen_name, presence: { allow_blank: false }
  validates :domain, format: { with: /\A[a-z0-9]+([-.]{1}[a-z0-9]+)*\.[a-z]{2,5}\z/ }, allow_nil: true,
                     uniqueness: true

  has_many :accounts, class_name: "OrganizationAccount", inverse_of: :organization, dependent: :destroy
  has_many :users, dependent: :nullify
  has_many :mentions, dependent: :restrict_with_error

  def account_for_provider?(provider)
    accounts.exists?(provider:)
  end
end
