# frozen_string_literal: true

require 'application_system_test_case'

require 'support/omniauth_helper'

class HomepageTest < ApplicationSystemTestCase
  include OmniauthHelper

  setup do
    visit login_path

    assert has_button?('Sign in with Google')

    add_oauth_mock_for_user(users(:john), user_accounts(:google_oauth2))
    click_button('Sign in with Google')
  end

  test 'guides user through the set-up process using x' do
    add_oauth_mock_for_organization(organizations(:respondo), organization_accounts(:x))
    page.find('#x-authorize-button').click
    handle_logout
  end

  test 'guides user through the set-up process using linkedin' do
    add_oauth_mock_for_organization(organizations(:respondo), organization_accounts(:linkedin))
    page.find('#linkedin-authorize-button').click
    handle_logout
  end

  private

  def handle_logout
    find_by_id('settings').click
    click_button('Sign Out')

    assert has_button?('Sign in with Google')
  end
end
