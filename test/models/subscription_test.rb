# frozen_string_literal: true

require 'test_helper'

class SubscriptionTest < ActiveSupport::TestCase
  def setup
    @subscription = Subscription.create!(
      external_uid: 'uid_1',
      status: :active,
      email: 'hello@respondo.com',
      cancel_url: 'https://respondo.com/cancel',
      update_url: 'https://respondo.com/update',
      brand: brands(:respondo)
    )
  end
  test 'validates presence of external_uid' do
    @subscription.external_uid = nil

    assert_not @subscription.save
  end

  test 'validates presence of status' do
    @subscription.status = nil

    assert_not @subscription.save
  end

  test 'validates presence of email' do
    @subscription.email = nil

    assert_not @subscription.save
  end

  test 'validates presence of cancel_url' do
    @subscription.cancel_url = nil

    assert_not @subscription.save
  end

  test 'validates presence of update_url' do
    @subscription.update_url = nil

    assert_not @subscription.save
  end

  [[:trialing, true], [:active, true], [:past_due, true], [:deleted, false]].each do |status_pair|
    test "#running? returns #{status_pair.second} when status is #{status_pair.first}" do
      @subscription.status = status_pair.first

      assert_equal status_pair.second, @subscription.running?
    end
  end
end
