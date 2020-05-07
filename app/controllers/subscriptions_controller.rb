# frozen_string_literal: true

class SubscriptionsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    if subscription.update(update_params)
      head :ok
    else
      head :bad_request
    end
  end

  private

  def update_params
    params.permit(:status, :email, :cancel_url, :update_url)
  end

  def passthrough
    JSON.parse(params[:passthrough]).with_indifferent_access
  end

  def brand
    Brand.find(passthrough[:brand_id])
  end

  def subscription
    brand.subscription || brand.build_subscription(external_uid: params[:subscription_id])
  end
end
