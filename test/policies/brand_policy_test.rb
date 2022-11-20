# frozen_string_literal: true

require 'test_helper'

class BrandPolicyTest < ActiveSupport::TestCase
  test 'denies access to edit? for guests' do
    assert_not_permit BrandPolicy, nil, brands(:respondo), :edit
  end

  test 'denies access to edit? for users outside of brand' do
    assert_not_permit BrandPolicy, users(:john), brands(:respondo), :edit
  end

  test 'allows access to edit? for users in brand' do
    brands(:respondo).users << users(:john)

    assert_permit BrandPolicy, users(:john), brands(:respondo), :edit
  end

  test 'denies access to update? for guests' do
    assert_not_permit BrandPolicy, nil, brands(:respondo), :update
  end

  test 'denies access to update? for users outside of brand' do
    assert_not_permit BrandPolicy, users(:john), brands(:respondo), :update
  end

  test 'allows access to update? for users in brand' do
    brands(:respondo).users << users(:john)

    assert_permit BrandPolicy, users(:john), brands(:respondo), :update
  end

  test 'denies access to subscription? when brand does not have subscription' do
    assert_not_permit BrandPolicy, users(:john), brands(:respondo), :subscription
  end

  test 'allows access to subscription? when brand has active subscription' do
    Subscription.create!(
      update_url: 'https://respondohub.com/update', cancel_url: 'https://respondohub.com/cancel',
      brand: brands(:respondo), external_uid: '123', email: 'support@respondohub.com', status: :active
    )

    assert_permit BrandPolicy, users(:john), brands(:respondo), :subscription
  end
end
