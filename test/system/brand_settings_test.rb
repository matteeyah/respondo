# frozen_string_literal: true

require 'application_system_test_case'

require 'omniauth_helper'
require 'sign_in_out_system_helper'

class BrandSettingsTest < ApplicationSystemTestCase
  include OmniauthHelper
  include SignInOutSystemHelper

  def setup
    visit '/'

    @brand = create(:brand, :with_account)
    user = sign_in_user
    user.update!(brand: @brand)
    sign_in_brand(@brand)
  end

  test 'allows the user to authorize an account' do
    find_by_id('settings').click
    click_link 'Brand settings'

    add_oauth_mock_for_brand(@brand, create(:brand_account, provider: 'disqus'))
    within(page.find(:css, 'div.list-group-item', text: 'Disqus')) do
      page.find(:button, 'Connect').click
    end

    within(page.find('p', text: 'Accounts').find(:xpath, '../..')) do
      assert has_selector?(:link, 'Remove')
    end
  end

  test 'allows the user to remove an account' do
    create(:brand_account, provider: 'disqus', brand: @brand)
    find_by_id('settings').click
    click_link 'Brand settings'

    within(page.find('p', text: 'Accounts').find(:xpath, '../..')) do
      within(page.find(:css, 'div.list-group-item', text: 'Disqus')) do
        page.find(:link, 'Remove').click
      end
    end

    within(page.find(:css, 'div.list-group-item', text: 'Disqus')) do
      assert has_selector?(:button, 'Connect')
    end
  end

  test 'allows the user to add users to brand' do
    external_user = create(:user)
    find_by_id('settings').click
    click_link 'Brand settings'
    click_button 'Team settings'

    select external_user.name, from: 'add-user'
    click_button 'Add'

    within(page.find('p', text: 'Brand team').find(:xpath, '../..')) do
      assert has_selector?(:link, 'Remove')
    end
  end

  test 'allows the user to remove users from brand' do
    existing_user = create(:user, brand: @brand)
    find_by_id('settings').click
    click_link 'Brand settings'
    click_button 'Team settings'

    within(page.find('p', text: 'Brand team').find(:xpath, '../..')) do
      within(page.find(:css, 'div.list-group-item', text: existing_user.name)) do
        page.find(:link, 'Remove').click
      end
    end

    within(page.find('p', text: 'Brand team').find(:xpath, '../..')) do
      assert has_no_text?(existing_user.name)
    end
  end

  test 'allows the user to edit the brand domain' do
    find_by_id('settings').click
    click_link 'Brand settings'
    click_button 'Team settings'

    fill_in 'brand[domain]', with: 'example.com'
    click_button 'Update'

    assert has_field?('brand[domain]', with: 'example.com')
  end

  test 'prevents the user to update the brand with an invalid domain' do
    find_by_id('settings').click
    click_link 'Brand settings'
    click_button 'Team settings'

    fill_in 'brand[domain]', with: 'invalid!domain.com'
    click_button 'Update'

    assert has_field?('brand[domain]', with: 'invalid!domain.com')
  end
end
