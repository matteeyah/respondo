# frozen_string_literal: true

class Subscription < ApplicationRecord
  belongs_to :brand

  enum status: { active: 0, trialing: 1, paused: 2, deleted: 3 }

  validates :external_uid, presence: { allow_blank: false }
  validates :status, presence: true
  validates :email, presence: { allow_blank: false }
  validates :cancel_url, presence: { allow_blank: false }
  validates :update_url, presence: { allow_blank: false }
end
