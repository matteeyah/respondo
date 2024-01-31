# frozen_string_literal: true

require "application_system_test_case"

require "support/omniauth_helper"

class HomepageTest < ApplicationSystemTestCase
  include OmniauthHelper

  setup do
    visit login_path

    assert_button("Sign in with Google")

    add_oauth_mock_for_user(users(:john), user_accounts(:google_oauth2))
    click_button("Sign in with Google")
  end

  test "guides user through the set-up process using x" do
    add_oauth_mock_for_organization(organizations(:respondo), organization_accounts(:x))
    find_icon_link("twitter").click
    logout
  end

  test "guides user through the set-up process using linkedin" do
    add_oauth_mock_for_organization(organizations(:respondo), organization_accounts(:linkedin))
    find_icon_link("linkedin").click
    logout
  end

  private

  def logout
    find_by_id("settings").click
    click_button("Sign Out")

    assert_button("Sign in with Google")
  end
end
