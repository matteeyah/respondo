# frozen_string_literal: true

require 'application_system_test_case'

require 'support/omniauth_helper'
require 'support/authentication_helper'

class OrganizationSettingsTest < ApplicationSystemTestCase
  include OmniauthHelper
  include AuthenticationHelper

  def setup
    @user = users(:john)
    @organization = organizations(:respondo)

    visit '/'

    sign_in_user(@user)
    sign_in_organization(@organization)

    find_by_id('settings').click
  end

  test 'allows the user to authorize an account' do
    click_link 'Organization settings'

    account = Struct.new(:provider, :external_uid, :token, :secret).new(:disqus, 'uid_20')
    add_oauth_mock_for_organization(@organization, account)
    within(page.find('p', text: 'Add account').find(:xpath, '../..')) do
      within(page.find(:css, 'div.list-group-item', text: 'Disqus')) do
        page.find(:button, 'Connect').click
      end
    end

    within(page.find('p', text: 'Existing accounts').find(:xpath, '../..')) do
      assert has_selector?(:css, 'div.list-group-item', text: 'Disqus', count: 2)
    end
  end

  test 'allows the user to remove an account' do
    click_link 'Organization settings'

    within(page.find('p', text: 'Existing accounts').find(:xpath, '../..')) do
      within(page.find(:css, 'div.list-group-item', text: 'Disqus')) do
        page.find(:link, 'Remove').click
      end
    end

    within(page.find('p', text: 'Add account').find(:xpath, '../..')) do
      within(page.find(:css, 'div.list-group-item', text: 'Disqus')) do
        assert has_selector?(:button, 'Connect')
      end
    end
  end

  test 'allows the user to add users to organization' do
    external_user = users(:other)
    click_link 'Organization settings'

    click_button 'Team'

    select external_user.name, from: 'add-user'
    click_button 'Add'

    within(page.find('p', text: 'Team').find(:xpath, '../..')) do
      within(page.find('span', text: external_user.name).find(:xpath, '../..')) do
        assert has_selector?(:link, 'Remove')
      end
    end
  end

  test 'allows the user to remove users from organization' do
    existing_user = users(:other)
    existing_user.update!(organization: @organization)
    click_link 'Organization settings'

    click_button 'Team'

    within(page.find('p', text: 'Team').find(:xpath, '../..')) do
      within(page.find(:css, 'div.list-group-item', text: existing_user.name)) do
        page.find(:link, 'Remove').click
      end
    end

    within(page.find('p', text: 'Team').find(:xpath, '../..')) do
      assert has_no_text?(existing_user.name)
    end
  end

  test 'allows the user to edit the organization domain' do
    click_link 'Organization settings'

    click_button 'Team'

    fill_in 'organization[domain]', with: 'example.com'
    click_button 'Update'

    assert has_field?('organization[domain]', with: 'example.com')
  end

  test 'prevents the user to update the organization with an invalid domain' do
    click_link 'Organization settings'

    click_button 'Team'

    fill_in 'organization[domain]', with: 'invalid!domain.com'
    click_button 'Update'

    assert has_field?('organization[domain]', with: 'invalid!domain.com')
  end
end
