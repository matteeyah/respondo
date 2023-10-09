# frozen_string_literal: true

require 'application_system_test_case'

require 'support/omniauth_helper'
require 'support/authentication_helper'

class UserSettingsTest < ApplicationSystemTestCase
  include OmniauthHelper
  include AuthenticationHelper

  setup do
    @user = users(:john)

    sign_in(@user)
  end

  test 'allows the user to authorize an account' do
    user_accounts(:azure_activedirectory_v2).destroy
    visit profile_path

    account = Struct.new(:provider, :external_uid, :name, :email).new(:azure_activedirectory_v2, 'uid_20')
    add_oauth_mock_for_user(@user, account)
    within(page.find('p', text: 'Add account').find(:xpath, '../..')) do
      within(page.find(:css, 'div.list-group-item', text: 'Azure Active Directory')) do
        page.find(:button, text: 'Connect').click
      end
    end

    within(page.find('p', text: 'Existing accounts').find(:xpath, '../..')) do
      within(page.find(:css, 'div.list-group-item', text: 'Azure Active Directory')) do
        assert has_selector?(:link, 'Remove')
      end
    end
  end

  test 'allows the user to remove an account' do
    visit profile_path

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
    visit profile_path
    click_button 'Access'

    fill_in :name, with: 'something_nice'
    click_button 'Create'

    within(page.find('p', text: 'Personal Access Tokens').find(:xpath, '../..')) do
      assert has_selector?(:link, 'Remove', count: 2)
    end
  end

  test 'allows the user to remove a personal access token' do
    visit profile_path
    pat = personal_access_tokens(:default)

    click_button 'Access'

    within(page.find('p', text: 'Personal Access Tokens').find(:xpath, '../..')) do
      page.find(:link, 'Remove').click
    end

    assert has_no_text?(pat.name)
  end
end
