# frozen_string_literal: true

require "test_helper"

require "support/authentication_request_helper"

class OmniauthCallbacksControllerTest < ActionDispatch::IntegrationTest
  include AuthenticationRequestHelper
  include OmniauthHelper

  test "POST user creates User" do
    OmniAuth.config.add_mock(:google_oauth2, JSON.parse(file_fixture("google_oauth.json").read))

    assert_changes -> { User.count }, from: 2, to: 3 do
      post "/auth/google_oauth2"
      follow_redirect!
    end
  end

  test "POST user creates UserAccount" do
    OmniAuth.config.add_mock(:google_oauth2, JSON.parse(file_fixture("google_oauth.json").read))

    assert_changes -> { UserAccount.count }, from: 2, to: 3 do
      post "/auth/google_oauth2"
      follow_redirect!
    end
  end

  test "POST user when user and account exist does not create duplicates" do
    add_oauth_mock_for_user(users(:john), user_accounts(:google_oauth2))

    assert_no_changes -> { "#{UserAccount.count}#{User.count}" } do
      post "/auth/google_oauth2"
      follow_redirect!
    end
  end

  test "POST user redirects to root" do
    OmniAuth.config.add_mock(:google_oauth2, JSON.parse(file_fixture("google_oauth.json").read))

    post "/auth/google_oauth2"
    follow_redirect!

    assert_redirected_to root_path
  end

  test "POST organization when user is not logged in redirects to login" do
    OmniAuth.config.add_mock(:twitter, JSON.parse(file_fixture("x_oauth.json").read))

    post "/auth/twitter"
    follow_redirect!

    assert_redirected_to login_path
  end

  test "POST organization creates Organization" do
    sign_in(users(:john), user_accounts(:google_oauth2))
    OmniAuth.config.add_mock(:twitter, JSON.parse(file_fixture("x_oauth.json").read))

    assert_changes -> { Organization.count }, from: 2, to: 3 do
      post "/auth/twitter"
      follow_redirect!
    end
  end

  test "POST organization creates OrganizationAccount" do
    sign_in(users(:john), user_accounts(:google_oauth2))
    OmniAuth.config.add_mock(:twitter, JSON.parse(file_fixture("x_oauth.json").read))

    assert_changes -> { OrganizationAccount.count }, from: 2, to: 3 do
      post "/auth/twitter"
      follow_redirect!
    end
  end

  test "POST organization when user and account exist does not create duplicates" do
    sign_in(users(:john), user_accounts(:google_oauth2))
    add_oauth_mock_for_organization(organizations(:respondo), organization_accounts(:x))

    assert_no_changes -> { "#{OrganizationAccount.count}#{Organization.count}" } do
      post "/auth/twitter"
      follow_redirect!
    end
  end

  test "POST organization associates organization with user" do
    sign_in(users(:john), user_accounts(:google_oauth2))
    OmniAuth.config.add_mock(:twitter, JSON.parse(file_fixture("x_oauth.json").read))

    assert_changes -> { users(:john).reload.organization }, from: nil do
      post "/auth/twitter"
      follow_redirect!
    end
  end

  test "POST organization redirects to root" do
    sign_in(users(:john), user_accounts(:google_oauth2))
    OmniAuth.config.add_mock(:twitter, JSON.parse(file_fixture("x_oauth.json").read))

    post "/auth/twitter"
    follow_redirect!

    assert_redirected_to root_path
  end
end
