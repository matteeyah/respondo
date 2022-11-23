# frozen_string_literal: true

require 'test_helper'

class SubscriptionsControllerTest < ActionDispatch::IntegrationTest
  test 'POST create when subscription is being created' do
    assert_changes -> { Subscription.count }, from: 0, to: 1 do
      post '/subscriptions.json', params: subscription_webhook_parameters, as: :json
    end

    assert_response :ok
  end

  test 'POST create when subscription is being updated' do
    subscription = Subscription.create!(
      external_uid: 'uid_1', status: 'active', email: 'hello@respondohub.com', brand: brands(:respondo),
      cancel_url: 'https://respondohub.com/cancel', update_url: 'https://respondohub.com/update'
    )

    assert_changes -> { subscription.reload.email }, from: 'hello@respondohub.com', to: 'test@respondohub.com' do
      post '/subscriptions.json',
           params: subscription_webhook_parameters.merge(
             subscription_id: subscription.external_uid
           ), as: :json
    end

    assert_response :ok
  end

  test 'POST create when subscription is being cancelled' do
    subscription = Subscription.create!(
      external_uid: 'uid_1', status: 'active', email: 'hello@respondohub.com', brand: brands(:respondo),
      cancel_url: 'https://respondohub.com/cancel', update_url: 'https://respondohub.com/update'
    )

    assert_changes -> { subscription.reload.status }, from: 'active', to: 'deleted' do
      post '/subscriptions.json',
           params: subscription_webhook_parameters.merge(
             subscription_id: subscription.external_uid, status: 'deleted'
           ), as: :json
    end

    assert_response :ok
  end

  test 'POST create when parameters are invalid' do
    post '/subscriptions.json', params: subscription_webhook_parameters.except(:email), as: :json

    assert_response :bad_request
  end

  private

  def subscription_webhook_parameters
    {
      subscription_id: 1,
      status: 'active',
      email: 'test@respondohub.com',
      update_url: 'https://respondohub.com/update',
      cancel_url: 'https://respondohub.com/cancel',
      passthrough: "{ \"brand_id\": #{brands(:respondo).id} }"
    }
  end
end
