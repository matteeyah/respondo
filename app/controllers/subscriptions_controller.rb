# frozen_string_literal: true

class SubscriptionsController < ApplicationController
  def create
    subscription.update(update_params)
  end

  private

  def subscription
    Subscription.find_or_initialize_by(id: params[:subscription_id])
  end

  def update_params
    params.permit(:status, :email, :cancel_url, :update_url)
  end
end
