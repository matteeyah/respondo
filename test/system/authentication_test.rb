# frozen_string_literal: true

require 'application_system_test_case'
require 'minitest/mock'

require 'support/omniauth_helper'
require 'support/authentication_helper'

class AuthenticationTest < ApplicationSystemTestCase
  include ActiveJob::TestHelper
  include OmniauthHelper
  include AuthenticationHelper

  test 'allows user creation' do
    visit '/'

    add_oauth_mock(:google_oauth2, '123', { name: 'Test User', email: 'test@example.com' }, {})
    click_button('Sign in with Google')
    find_by_id('settings').click

    assert has_link?('User settings')
  end

  test 'adds the user to the brand' do
    brands(:respondo).update!(domain: 'example.com')

    visit '/'

    add_oauth_mock(:google_oauth2, '123', { name: 'Test User', email: 'test@example.com' }, {})
    click_button('Sign in with Google')

    assert has_link?('Tickets')
  end

  test 'allows brand creation' do
    visit '/'

    sign_in_user

    add_oauth_mock(:twitter, '123', { nickname: 'test_brand' }, {})
    click_button('Authorize')

    assert_enqueued_with(job: LoadNewTicketsJob)

    find_by_id('settings').click

    assert has_link?('Brand settings')
  end

  test 'allows signing out' do
    visit '/'

    sign_in_user
    find_by_id('settings').click
    click_button 'Sign Out'

    assert_current_path(login_path)
  end
end
