# frozen_string_literal: true

require 'test_helper'

class BrandAccountTest < ActiveSupport::TestCase
  test 'validates presence of provider' do
    account = brand_accounts(:twitter)
    account.provider = nil

    assert_predicate account, :invalid?
  end

  test 'validates presence of external_uid' do
    account = brand_accounts(:twitter)
    account.external_uid = nil

    assert_predicate account, :invalid?
  end

  test 'validates email is not blank' do
    account = brand_accounts(:twitter)
    account.email = '  '

    assert_predicate account, :invalid?
  end

  test 'validates screen_name is not blank' do
    account = brand_accounts(:twitter)
    account.screen_name = '  '

    assert_predicate account, :invalid?
  end

  test 'validates uniqueness of external_uid' do
    account = brand_accounts(:twitter).dup

    assert_predicate account, :invalid?
    assert account.errors.added?(:external_uid, :taken, value: 'uid_1')
  end

  test '.from_omniauth returns a brand account' do
    oauth_response = JSON.parse(file_fixture('twitter_oauth.json').read)
    auth_hash = OmniAuth::AuthHash.new(oauth_response)

    assert_instance_of BrandAccount, BrandAccount.from_omniauth(auth_hash, nil)
  end

  test '.from_omniauth creates an account when it does not exist' do
    oauth_response = JSON.parse(file_fixture('twitter_oauth.json').read)
    auth_hash = OmniAuth::AuthHash.new(oauth_response)

    assert_difference -> { BrandAccount.count }, 1 do
      BrandAccount.from_omniauth(auth_hash, nil)
    end
  end

  test '.from_omniauth creates a brand when it does not exist' do
    oauth_response = JSON.parse(file_fixture('twitter_oauth.json').read)
    auth_hash = OmniAuth::AuthHash.new(oauth_response)

    assert_difference -> { Brand.count }, 1 do
      BrandAccount.from_omniauth(auth_hash, nil)
    end
  end

  test '.from_omniauth finds an account when it exists' do
    oauth_response = JSON.parse(file_fixture('twitter_oauth.json').read)
    auth_hash = OmniAuth::AuthHash.new(oauth_response)
    brand_accounts(:twitter).update!(external_uid: auth_hash.uid)

    assert_no_difference -> { BrandAccount.count } do
      BrandAccount.from_omniauth(auth_hash, nil)
    end
  end

  test '.from_omniauth updates account ownership when it belongs to a different brand' do
    oauth_response = JSON.parse(file_fixture('twitter_oauth.json').read)
    auth_hash = OmniAuth::AuthHash.new(oauth_response)
    account = brand_accounts(:twitter)
    account.update!(external_uid: auth_hash.uid)

    assert_changes -> { account.reload.brand }, from: brands(:respondo), to: brands(:other) do
      BrandAccount.from_omniauth(auth_hash, brands(:other))
    end
  end

  test '.from_omniauth updates the account email' do
    oauth_response = JSON.parse(file_fixture('twitter_oauth.json').read)
    auth_hash = OmniAuth::AuthHash.new(oauth_response)
    auth_hash.info.email = 'hello@world.com'
    account = brand_accounts(:twitter)
    account.update!(external_uid: auth_hash.uid)

    assert_changes -> { account.reload.email }, from: nil, to: 'hello@world.com' do
      BrandAccount.from_omniauth(auth_hash, nil)
    end
  end

  test '.from_omniauth updates the account screen_name' do
    oauth_response = JSON.parse(file_fixture('twitter_oauth.json').read)
    auth_hash = OmniAuth::AuthHash.new(oauth_response)
    account = brand_accounts(:twitter)
    account.update!(external_uid: auth_hash.uid)

    assert_changes -> { account.reload.screen_name }, from: 'respondo', to: 'johnqpublic' do
      BrandAccount.from_omniauth(auth_hash, nil)
    end
  end

  test '.from_omniauth updates the account credentials' do
    oauth_response = JSON.parse(file_fixture('twitter_oauth.json').read)
    auth_hash = OmniAuth::AuthHash.new(oauth_response)
    account = brand_accounts(:twitter)
    account.update!(external_uid: auth_hash.uid)

    assert_changes -> { account.reload.token }, from: nil, to: 'a1b2c3d4...' do
      BrandAccount.from_omniauth(auth_hash, nil)
    end
  end

  test '#new_mentions asks for a full list of tickets when there are no tickets' do
    account = brand_accounts(:twitter)
    account.update!(token: 'hello', secret: 'world')
    account.internal_tickets.destroy_all

    stubbed_twitter_request = stub_request(:get, 'https://api.twitter.com/1.1/statuses/mentions_timeline.json?tweet_mode=extended').to_return(
      status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
      body: file_fixture('twitter_mentions_timeline.json').read
    )
    account.new_mentions

    assert_requested(stubbed_twitter_request)
  end

  test '#new_mentions uses last ticket identifier when account has tickets' do
    account = brand_accounts(:twitter)
    account.update!(token: 'hello', secret: 'world')

    stubbed_twitter_request = stub_request(:get, 'https://api.twitter.com/1.1/statuses/mentions_timeline.json?since_id=uid_1&tweet_mode=extended').to_return(
      status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
      body: file_fixture('twitter_mentions_timeline.json').read
    )
    account.new_mentions

    assert_requested(stubbed_twitter_request)
  end

  BrandAccount.providers.except(:developer).each_key do |provider|
    test "#client returns a client for #{provider}" do
      account = brand_accounts(:twitter)
      account.provider = provider

      assert_kind_of Clients::ProviderClient, account.client
    end
  end
end
