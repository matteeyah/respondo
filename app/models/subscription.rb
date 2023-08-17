# frozen_string_literal: true

class Subscription < ApplicationRecord
  belongs_to :organization

  enum status: { trialing: 0, active: 1, past_due: 2, deleted: 3 }

  validates :external_uid, presence: { allow_blank: false }
  validates :status, presence: true
  validates :email, presence: { allow_blank: false }
  validates :cancel_url, presence: { allow_blank: false }
  validates :update_url, presence: { allow_blank: false }

  def change_quantity(new_quantity)
    paddle_client.change_quantity(external_uid, new_quantity)
  end

  def running?
    active? || trialing? || past_due?
  end

  private

  def paddle_client
    @paddle_client ||= Clients::Paddle.new(vendor_id, vendor_auth)
  end

  def vendor_id
    @vendor_id ||= Rails.application.credentials.paddle.vendor_id
  end

  def vendor_auth
    @vendor_auth ||= Rails.application.credentials.paddle.vendor_auth
  end
end
