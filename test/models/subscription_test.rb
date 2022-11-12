# frozen_string_literal: true

require 'test_helper'

class SubscriptionTest < ActiveSupport::TestCase
  test 'validates presence of external_uid' do
    subscription = create(:subscription)
    subscription.external_uid = nil

    assert_not subscription.save
  end

  test 'validates presence of status' do
    subscription = create(:subscription)
    subscription.status = nil

    assert_not subscription.save
  end

  test 'validates presence of email' do
    subscription = create(:subscription)
    subscription.email = nil

    assert_not subscription.save
  end

  test 'validates presence of cancel_url' do
    subscription = create(:subscription)
    subscription.cancel_url = nil

    assert_not subscription.save
  end

  test 'validates presence of update_url' do
    subscription = create(:subscription)
    subscription.update_url = nil

    assert_not subscription.save
  end

  [[:trialing, true], [:active, true], [:past_due, true], [:deleted, false]].each do |status_pair|
    test "#running? returns #{status_pair.second} when status is #{status_pair.first}" do
      subscription = create(:subscription, status: status_pair.first)

      assert_equal status_pair.second, subscription.running?
    end
  end
end
