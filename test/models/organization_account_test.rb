# frozen_string_literal: true

require "test_helper"

class OrganizationAccountTest < ActiveSupport::TestCase
  test "validates presence of provider" do
    account = organization_accounts(:x)
    account.provider = nil

    assert_predicate account, :invalid?
  end

  test "validates presence of external_uid" do
    account = organization_accounts(:x)
    account.external_uid = nil

    assert_predicate account, :invalid?
  end

  test "validates email is not blank" do
    account = organization_accounts(:x)
    account.email = "  "

    assert_predicate account, :invalid?
  end

  test "validates screen_name is not blank" do
    account = organization_accounts(:x)
    account.screen_name = "  "

    assert_predicate account, :invalid?
  end

  test "validates uniqueness of external_uid" do
    account = organization_accounts(:x).dup

    assert_predicate account, :invalid?
    assert account.errors.added?(:external_uid, :taken, value: "uid_1")
  end

  test ".from_omniauth returns a organization account" do
    oauth_response = JSON.parse(file_fixture("x_oauth.json").read)
    auth_hash = OmniAuth::AuthHash.new(oauth_response)

    assert_instance_of OrganizationAccount, OrganizationAccount.from_omniauth(auth_hash, nil)
  end

  test ".from_omniauth creates an account when it does not exist" do
    oauth_response = JSON.parse(file_fixture("x_oauth.json").read)
    auth_hash = OmniAuth::AuthHash.new(oauth_response)

    assert_difference -> { OrganizationAccount.count }, 1 do
      OrganizationAccount.from_omniauth(auth_hash, nil)
    end
  end

  test ".from_omniauth creates a organization when it does not exist" do
    oauth_response = JSON.parse(file_fixture("x_oauth.json").read)
    auth_hash = OmniAuth::AuthHash.new(oauth_response)

    assert_difference -> { Organization.count }, 1 do
      OrganizationAccount.from_omniauth(auth_hash, nil)
    end
  end

  test ".from_omniauth finds an account when it exists" do
    oauth_response = JSON.parse(file_fixture("x_oauth.json").read)
    auth_hash = OmniAuth::AuthHash.new(oauth_response)
    organization_accounts(:x).update!(external_uid: auth_hash.uid)

    assert_no_difference -> { OrganizationAccount.count } do
      OrganizationAccount.from_omniauth(auth_hash, nil)
    end
  end

  test ".from_omniauth updates account ownership when it belongs to a different organization" do
    oauth_response = JSON.parse(file_fixture("x_oauth.json").read)
    auth_hash = OmniAuth::AuthHash.new(oauth_response)
    account = organization_accounts(:x)
    account.update!(external_uid: auth_hash.uid)

    assert_changes -> { account.reload.organization }, from: organizations(:respondo), to: organizations(:other) do
      OrganizationAccount.from_omniauth(auth_hash, organizations(:other))
    end
  end

  test ".from_omniauth updates the account email" do
    oauth_response = JSON.parse(file_fixture("x_oauth.json").read)
    auth_hash = OmniAuth::AuthHash.new(oauth_response)
    auth_hash.info.email = "hello@world.com"
    account = organization_accounts(:x)
    account.update!(external_uid: auth_hash.uid)

    assert_changes -> { account.reload.email }, from: nil, to: "hello@world.com" do
      OrganizationAccount.from_omniauth(auth_hash, nil)
    end
  end

  test ".from_omniauth updates the account screen_name" do
    oauth_response = JSON.parse(file_fixture("x_oauth.json").read)
    auth_hash = OmniAuth::AuthHash.new(oauth_response)
    account = organization_accounts(:x)
    account.update!(external_uid: auth_hash.uid)

    assert_changes -> { account.reload.screen_name }, from: "respondo", to: "johnqpublic" do
      OrganizationAccount.from_omniauth(auth_hash, nil)
    end
  end

  test ".from_omniauth updates the account credentials" do
    oauth_response = JSON.parse(file_fixture("x_oauth.json").read)
    auth_hash = OmniAuth::AuthHash.new(oauth_response)
    account = organization_accounts(:x)
    account.update!(external_uid: auth_hash.uid)

    assert_changes -> { account.reload.token }, from: nil, to: "a1b2c3d4..." do
      OrganizationAccount.from_omniauth(auth_hash, nil)
    end
  end

  test "#new_mentions asks for a full list of mentions when there are no mentions" do
    account = organization_accounts(:x)
    account.update!(token: "hello", secret: "world")
    account.mentions.destroy_all

    stub_request(:get, "https://api.twitter.com/2/users/me").to_return(
      status: 200, headers: { "Content-Type" => "application/json; charset=utf-8" },
      body: file_fixture("x_users_me.json")
    )
    stubbed_x_request = stub_request(:get, "https://api.twitter.com/2/users/2244994945/mentions?expansions=author_id,referenced_tweets.id&tweet.fields=created_at").to_return(
      status: 200, headers: { "Content-Type" => "application/json; charset=utf-8" },
      body: file_fixture("x_mentions.json").read
    )
    account.new_mentions

    assert_requested(stubbed_x_request)
  end

  test "#new_mentions uses last mention identifier when account has mentions" do
    account = organization_accounts(:x)
    account.update!(token: "hello", secret: "world")

    stub_request(:get, "https://api.twitter.com/2/users/me").to_return(
      status: 200, headers: { "Content-Type" => "application/json; charset=utf-8" },
      body: file_fixture("x_users_me.json")
    )
    stubbed_x_request = stub_request(:get, "https://api.twitter.com/2/users/2244994945/mentions?expansions=author_id,referenced_tweets.id&since_id=uid_1&tweet.fields=created_at").to_return(
      status: 200, headers: { "Content-Type" => "application/json; charset=utf-8" },
      body: file_fixture("x_mentions.json").read
    )
    account.new_mentions

    assert_requested(stubbed_x_request)
  end

  OrganizationAccount.providers.each_key do |provider|
    test "#client returns a client for #{provider}" do
      account = organization_accounts(:x)
      account.provider = provider

      assert_kind_of Clients::ProviderClient, account.client
    end
  end
end
