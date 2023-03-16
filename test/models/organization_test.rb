# frozen_string_literal: true

require 'test_helper'

class OrganizationTest < ActiveSupport::TestCase
  test 'validates presence of screen_name' do
    organization = organizations(:respondo)
    organization.screen_name = nil

    assert_predicate organization, :invalid?
  end

  test 'validates format of domain' do
    organization = organizations(:respondo)
    organization.domain = 'invalid!respondohub.com'

    assert_predicate organization, :invalid?
  end

  test 'validates uniqueness of domain' do
    organization = organizations(:respondo)
    organizations(:other).update!(domain: 'respondohub.com')
    organization.domain = 'respondohub.com'

    assert_predicate organization, :invalid?
    assert organization.errors.added?(:domain, :taken, value: 'respondohub.com')
  end

  test 'increases subscription quantity when adding a user to the team' do
    organization = organizations(:respondo)
    Subscription.create!(
      external_uid: '123', email: 'billing@respondohub.com', status: :active, organization:,
      cancel_url: 'https://respondohub.com/cancel', update_url: 'https://respondohub.com/update'
    )
    stubbed_paddle_request = stub_request(:post, 'https://vendors.paddle.com/api/2.0/subscription/users/update')
      .with(body: { 'quantity' => '1', 'subscription_id' => '123', 'vendor_auth_code' => nil, 'vendor_id' => nil })
      .and_return(status: 200)

    organization.users << users(:john)

    assert_requested(stubbed_paddle_request)
  end

  test 'decreases subscription quantity when removing a user from the team' do
    organization = organizations(:respondo)
    users(:john).update!(organization:)
    Subscription.create!(
      external_uid: '123', email: 'billing@respondohub.com', status: :active, organization:,
      cancel_url: 'https://respondohub.com/cancel', update_url: 'https://respondohub.com/update'
    )
    stubbed_paddle_request = stub_request(:post, 'https://vendors.paddle.com/api/2.0/subscription/users/update')
      .with(body: { 'quantity' => '0', 'subscription_id' => '123', 'vendor_auth_code' => nil, 'vendor_id' => nil })
      .and_return(status: 200)

    organization.users.delete(users(:john))

    assert_requested(stubbed_paddle_request)
  end

  OrganizationAccount.providers.each_key do |provider_name|
    test "#account_for_provider? returns true when there is an #{provider_name} account" do
      OrganizationAccount.create!(screen_name: 'respondo', external_uid: 'hello_world', provider: provider_name,
                                  organization: organizations(:other))

      assert organizations(:other).account_for_provider?(provider_name)
    end

    test "#account_for_provider? returns false when there is no #{provider_name} account" do
      assert_not organizations(:other).account_for_provider?(provider_name)
    end
  end
end
