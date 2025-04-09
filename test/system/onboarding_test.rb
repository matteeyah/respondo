# frozen_string_literal: true

require "application_system_test_case"

require "support/omniauth_helper"

class OnboardingTest < ApplicationSystemTestCase
  include OmniauthHelper

  setup do
    visit login_path

    assert_button("Sign in with Google")

    add_oauth_mock_for_user(users(:john), user_accounts(:google_oauth2))
    click_button("Sign in with Google")
  end

  test "guides user through the set-up process using x" do
    add_oauth_mock_for_organization(organizations(:respondo), organization_accounts(:x))
    click_button("Authorize Twitter")
    logout
  end

  test "guides user through the set-up process using linkedin" do
    add_oauth_mock_for_organization(organizations(:respondo), organization_accounts(:linkedin))
    click_button("Authorize LinkedIn")
    logout
  end

  private

  def logout
    click_link("Settings")

    click_button("user-menu-button")
    click_button("Sign out")

    assert_button("Sign in with Google")
  end
end
