# frozen_string_literal: true

require 'application_system_test_case'

require 'support/omniauth_helper'
require 'support/authentication_helper'

class UserSettingsTest < ApplicationSystemTestCase
  include OmniauthHelper
  include AuthenticationHelper

  def setup
    @user = users(:john)

    visit '/'

    sign_in_user(@user)

    find_by_id('settings').click
  end

  test 'allows the user to authorize an account' do
    user_accounts(:activedirectory).destroy
    click_link 'User profile'

    account = Struct.new(:provider, :external_uid, :name, :email).new(:activedirectory, 'uid_20')
    add_oauth_mock_for_user(@user, account)
    within(page.find('p', text: 'Add account').find(:xpath, '../..')) do
      within(page.find(:css, 'div.list-group-item', text: 'Azure Active Directory')) do
        page.find(:button, text: 'Connect').click
      end
    end

    within(page.find('p', text: 'Accounts').find(:xpath, '../..')) do
      within(page.find(:css, 'div.list-group-item', text: 'Azure Active Directory')) do
        assert has_selector?(:link, 'Remove')
      end
    end
  end

  test 'allows the user to remove an account' do
    click_link 'User profile'

    within(page.find('p', text: 'Existing accounts').find(:xpath, '../..')) do
      within(page.find(:css, 'div.list-group-item', text: 'Azure Active Directory')) do
        page.find(:link, 'Remove').click
      end
    end

    within(page.find(:css, 'div.list-group-item', text: 'Azure Active Directory')) do
      assert has_selector?(:button, 'Connect')
    end
  end

  test 'allows the user to create a personal access token' do
    click_link 'User profile'

    click_button 'Access'

    fill_in :name, with: 'something_nice'
    click_button 'Create'

    within(page.find('p', text: 'Personal Access Tokens').find(:xpath, '../..')) do
      assert has_selector?(:link, 'Remove', count: 2)
    end
  end

  test 'allows the user to remove a personal access token' do
    pat = personal_access_tokens(:default)
    click_link 'User profile'

    click_button 'Access'

    within(page.find('p', text: 'Personal Access Tokens').find(:xpath, '../..')) do
      page.find(:link, 'Remove').click
    end

    assert has_no_text?(pat.name)
  end
end
