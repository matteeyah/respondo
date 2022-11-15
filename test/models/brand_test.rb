# frozen_string_literal: true

require 'test_helper'

class BrandTest < ActiveSupport::TestCase
  test 'validates presence of screen_name' do
    brand = brands(:respondo)
    brand.screen_name = nil

    assert_not brand.valid?
  end

  test 'validates format of domain' do
    brand = brands(:respondo)
    brand.domain = 'invalid!respondohub.com'

    assert_not brand.valid?
  end

  test 'validates uniqueness of domain' do
    brand = brands(:respondo)
    brands(:other).update!(domain: 'respondohub.com')
    brand.domain = 'respondohub.com'

    assert_not brand.valid?
  end

  test 'increases subscription quantity when adding a user to the team' do
    brand = brands(:respondo)
    Subscription.create!(
      external_uid: '123', email: 'billing@respondohub.com', status: :active, brand:,
      cancel_url: 'https://respondohub.com/cancel', update_url: 'https://respondohub.com/update'
    )
    stubbed_paddle_request = stub_request(:post, 'https://vendors.paddle.com/api/2.0/subscription/users/update')
      .with(body: { 'quantity' => '1', 'subscription_id' => '123', 'vendor_auth_code' => nil, 'vendor_id' => nil })
      .and_return(status: 200)

    brand.users << users(:john)

    assert_requested(stubbed_paddle_request)
  end

  test 'decreases subscription quantity when removing a user from the team' do
    brand = brands(:respondo)
    users(:john).update!(brand:)
    Subscription.create!(
      external_uid: '123', email: 'billing@respondohub.com', status: :active, brand:,
      cancel_url: 'https://respondohub.com/cancel', update_url: 'https://respondohub.com/update'
    )
    stubbed_paddle_request = stub_request(:post, 'https://vendors.paddle.com/api/2.0/subscription/users/update')
      .with(body: { 'quantity' => '0', 'subscription_id' => '123', 'vendor_auth_code' => nil, 'vendor_id' => nil })
      .and_return(status: 200)

    brand.users.delete(users(:john))

    assert_requested(stubbed_paddle_request)
  end

  BrandAccount.providers.each_key do |provider_name|
    test "#account_for_provider? returns true when there is an #{provider_name} account" do
      BrandAccount.create!(screen_name: 'respondo', external_uid: 'hello_world', provider: provider_name,
                           brand: brands(:other))

      assert brands(:other).account_for_provider?(provider_name)
    end

    test "#account_for_provider? returns false when there is no #{provider_name} account" do
      assert_not brands(:other).account_for_provider?(provider_name)
    end
  end
end
