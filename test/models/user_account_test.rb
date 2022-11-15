# frozen_string_literal: true

require 'test_helper'

class UserAccountTest < ActiveSupport::TestCase
  test 'validates presence of provider' do
    account = user_accounts(:google_oauth2)
    account.provider = nil

    assert_not account.valid?
  end

  test 'validates presence of external_uid' do
    account = user_accounts(:google_oauth2)
    account.external_uid = nil

    assert_not account.valid?
  end

  test 'validates email is not blank' do
    account = user_accounts(:google_oauth2)
    account.email = '  '

    assert_not account.valid?
  end

  test 'validates uniqueness of provider' do
    account = user_accounts(:google_oauth2).dup

    assert_not account.valid?
  end

  test '.from_omniauth returns a user account' do
    oauth_response = JSON.parse(file_fixture('google_oauth.json').read)
    auth_hash = OmniAuth::AuthHash.new(oauth_response)

    assert_instance_of UserAccount, UserAccount.from_omniauth(auth_hash, nil)
  end

  test '.from_omniniauth adds user to brand when account belongs to brand domain' do
    oauth_response = JSON.parse(file_fixture('google_oauth.json').read)
    auth_hash = OmniAuth::AuthHash.new(oauth_response)
    auth_hash.info.email = 'hello@respondohub.com'
    brand = brands(:respondo)
    brand.update!(domain: 'respondohub.com')
    account = user_accounts(:google_oauth2)

    assert_changes -> { account.user.reload.brand }, from: nil, to: brand do
      UserAccount.from_omniauth(auth_hash, users(:john))
    end
  end

  test '.from_omniauth creates an account when it does not exist' do
    oauth_response = JSON.parse(file_fixture('google_oauth.json').read)
    auth_hash = OmniAuth::AuthHash.new(oauth_response)

    assert_difference -> { UserAccount.count }, 1 do
      UserAccount.from_omniauth(auth_hash, nil)
    end
  end

  test '.from_omniauth creates a user when it does not exist' do
    oauth_response = JSON.parse(file_fixture('google_oauth.json').read)
    auth_hash = OmniAuth::AuthHash.new(oauth_response)

    assert_difference -> { User.count }, 1 do
      UserAccount.from_omniauth(auth_hash, nil)
    end
  end

  test '.from_omniauth finds an account when it exists' do
    oauth_response = JSON.parse(file_fixture('google_oauth.json').read)
    auth_hash = OmniAuth::AuthHash.new(oauth_response)
    user_accounts(:google_oauth2).update!(external_uid: auth_hash.uid)

    assert_no_difference -> { UserAccount.count } do
      UserAccount.from_omniauth(auth_hash, users(:john))
    end
  end

  test '.from_omniauth does not persist new account if user already has account for provider' do
    oauth_response = JSON.parse(file_fixture('google_oauth.json').read)
    auth_hash = OmniAuth::AuthHash.new(oauth_response)

    assert_not UserAccount.from_omniauth(auth_hash, users(:john)).persisted?
  end

  test '.from_omniauth updates account ownership when it belongs to other user' do
    oauth_response = JSON.parse(file_fixture('google_oauth.json').read)
    auth_hash = OmniAuth::AuthHash.new(oauth_response)
    account = user_accounts(:google_oauth2)
    account.update!(external_uid: auth_hash.uid)

    assert_changes -> { account.reload.user }, from: users(:john), to: users(:other) do
      UserAccount.from_omniauth(auth_hash, users(:other))
    end
  end

  test '.from_omniauth updates the account email' do
    oauth_response = JSON.parse(file_fixture('google_oauth.json').read)
    auth_hash = OmniAuth::AuthHash.new(oauth_response)
    auth_hash.info.email = 'hello@world.com'
    account = user_accounts(:google_oauth2)
    account.update!(external_uid: auth_hash.uid)

    assert_changes -> { account.reload.email }, from: nil, to: 'hello@world.com' do
      UserAccount.from_omniauth(auth_hash, nil)
    end
  end
end
