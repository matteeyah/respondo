# frozen_string_literal: true

require 'application_system_test_case'

require 'support/omniauth_helper'
require 'support/authentication_helper'

class UserSettingsTest < ApplicationSystemTestCase
  include OmniauthHelper
  include AuthenticationHelper

  def setup
    visit '/'

    @user = users(:john)
    sign_in_user(@user)
  end

  test 'allows the user to authorize an account' do
    find_by_id('settings').click
    click_link 'User settings'

    add_oauth_mock_for_user(@user, user_accounts(:activedirectory))
    within(page.find('p', text: 'Add account').find(:xpath, '../..')) do
      within(page.find(:css, 'div.list-group-item', text: 'Azure Active Directory')) do
        page.find(:button, text: 'Connect').click
      end
    end

    take_screenshot
    assert has_selector?(:link, 'Remove')
  end

  test 'allows the user to remove an account' do
    find_by_id('settings').click
    click_link 'User settings'

    within(page.find('p', text: 'Accounts').find(:xpath, '../..')) do
      within(page.find(:css, 'div.list-group-item', text: 'Azure Active Directory')) do
        page.find(:link, 'Remove').click
      end
    end

    within(page.find(:css, 'div.list-group-item', text: 'Azure Active Directory')) do
      assert has_selector?(:button, 'Connect')
    end
  end

  test 'allows the user to create a personal access token' do
    find_by_id('settings').click
    click_link 'User settings'
    click_button 'User settings'

    fill_in :name, with: 'something_nice'
    click_button 'Create'

    within(page.find('p', text: 'Personal Access Tokens').find(:xpath, '../..')) do
      assert has_selector?(:link, 'Remove')
    end
  end

  test 'allows the user to remove a personal access token' do
    pat = personal_access_tokens(:default)
    find_by_id('settings').click
    click_link 'User settings'
    click_button 'User settings'

    within(page.find('p', text: 'Personal Access Tokens').find(:xpath, '../..')) do
      page.find(:link, 'Remove').click
    end

    assert has_no_text?(pat.name)
  end
end
