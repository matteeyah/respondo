# frozen_string_literal: true

require "application_system_test_case"
require "minitest/mock"

require "support/omniauth_helper"
require "support/authentication_helper"

class AuthenticationTest < ApplicationSystemTestCase
  include ActiveJob::TestHelper
  include OmniauthHelper
  include AuthenticationHelper

  test "allows user creation" do
    visit login_path

    add_oauth_mock(:google_oauth2, "123", { name: "Test User", email: "test@example.com" }, {})
    click_button("Sign in with Google")
    find_by_id("user-menu-button").click

    assert_link("Your profile")
  end

  test "adds the user to the organization" do
    organizations(:respondo).update!(domain: "example.com")

    visit login_path

    add_oauth_mock(:google_oauth2, "123", { name: "Test User", email: "test@example.com" }, {})
    click_button("Sign in with Google")

    assert_link("Mentions")
  end

  test "allows organization creation" do
    sign_in(users(:john))

    add_oauth_mock(:twitter, "123", { nickname: "test_organization" }, {})
    visit root_path
    click_button("Authorize Twitter")

    assert_enqueued_jobs(1, only: LoadNewMentionsJob)

    assert_link("Settings")
  end

  test "allows signing out" do
    sign_in(users(:john))
    visit root_path

    find_by_id("user-menu-button").click
    click_button "Sign out"

    assert_current_path(login_path)
  end
end
