# frozen_string_literal: true

class Subscription < ApplicationRecord
  belongs_to :brand

  enum status: { trialing: 0, active: 1, past_due: 2, paused: 3, deleted: 4 }

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
    @paddle_client ||= Paddle::Client.new(ENV['PADDLE_VENDOR_ID'], ENV['PADDLE_VENDOR_AUTH'])
  end
end
