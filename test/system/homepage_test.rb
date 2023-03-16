# frozen_string_literal: true

require 'application_system_test_case'

require 'support/omniauth_helper'

class HomepageTest < ApplicationSystemTestCase
  include OmniauthHelper

  test 'guides user through the set-up process' do
    visit '/'

    assert has_button?('Sign in with Google')

    add_oauth_mock_for_user(users(:john), user_accounts(:google_oauth2))
    click_button('Sign in with Google')

    add_oauth_mock_for_organization(organizations(:respondo), organization_accounts(:twitter))
    click_button('Authorize', class: 'btn btn-primary')

    find_by_id('settings').click
    click_button('Sign Out')

    assert has_button?('Sign in with Google')
  end
end
