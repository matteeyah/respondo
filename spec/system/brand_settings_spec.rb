# frozen_string_literal: true

require './spec/support/omniauth_helpers'
require './spec/support/sign_in_out_system_helpers'

RSpec.describe 'Brand settings' do
  include OmniauthHelpers
  include SignInOutSystemHelpers

  let!(:brand) { create(:brand, :with_account) }

  before do
    visit '/'

    user = sign_in_user
    user.update!(brand:)
    sign_in_brand(brand)
  end

  it 'allows the user to authorize an account' do
    find_by_id('settings').click
    click_link 'Brand settings'

    add_oauth_mock_for_brand(brand, create(:brand_account, provider: 'disqus'))
    within(page.find(:css, 'div.list-group-item', text: 'Disqus')) do
      page.find(:button, 'Connect').click
    end

    within(page.find('p', text: 'Accounts').find(:xpath, '../..')) do
      expect(page).to have_selector(:link, 'Remove')
    end
  end

  it 'allows the user to remove an account' do
    create(:brand_account, provider: 'disqus', brand:)
    find_by_id('settings').click
    click_link 'Brand settings'

    within(page.find('p', text: 'Accounts').find(:xpath, '../..')) do
      within(page.find(:css, 'div.list-group-item', text: 'Disqus')) do
        page.find(:link, 'Remove').click
      end
    end

    within(page.find(:css, 'div.list-group-item', text: 'Disqus')) do
      expect(page).to have_selector(:button, 'Connect')
    end
  end

  it 'allows the user to add users to brand' do
    external_user = create(:user)
    find_by_id('settings').click
    click_link 'Brand settings'
    click_button 'Team settings'

    select external_user.name, from: 'add-user'
    click_button 'Add'

    within(page.find('p', text: 'Brand team').find(:xpath, '../..')) do
      expect(page).to have_selector(:link, 'Remove')
    end
  end

  it 'allows the user to remove users from brand' do
    existing_user = create(:user, brand:)
    find_by_id('settings').click
    click_link 'Brand settings'
    click_button 'Team settings'

    within(page.find('p', text: 'Brand team').find(:xpath, '../..')) do
      within(page.find(:css, 'div.list-group-item', text: existing_user.name)) do
        page.find(:link, 'Remove').click
      end
    end

    within(page.find('p', text: 'Brand team').find(:xpath, '../..')) do
      expect(page).not_to have_text(existing_user.name)
    end
  end

  it 'allows the user to edit the brand domain' do
    find_by_id('settings').click
    click_link 'Brand settings'
    click_button 'Team settings'

    fill_in 'brand[domain]', with: 'example.com'
    click_button 'Update'

    expect(page).to have_field('brand[domain]', with: 'example.com')
  end

  it 'prevents the user to update the brand with an invalid domain' do
    find_by_id('settings').click
    click_link 'Brand settings'
    click_button 'Team settings'

    fill_in 'brand[domain]', with: 'invalid!domain.com'
    click_button 'Update'

    expect(page).to have_field('brand[domain]', with: 'invalid!domain.com')
  end
end
