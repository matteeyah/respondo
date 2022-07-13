# frozen_string_literal: true

require './spec/support/omniauth_helpers'
require './spec/support/sign_in_out_system_helpers'

RSpec.describe 'Brand settings', type: :system do
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
    find('#settings').click
    click_link 'Brand settings'

    add_oauth_mock_for_brand(brand, create(:brand_account, provider: 'disqus'))
    within(page.find(:css, 'div.list-group-item', text: 'Disqus')) do
      page.find(:css, 'i.bi-plus-lg').click
    end

    within(page.find('h6', text: 'Existing accounts').find(:xpath, '..')) do
      expect(page).to have_selector(:css, 'i.bi-trash3-fill')
    end
  end

  it 'allows the user to remove an account' do
    create(:brand_account, provider: 'disqus', brand:)
    find('#settings').click
    click_link 'Brand settings'

    within(page.find('h6', text: 'Existing accounts').find(:xpath, '..')) do
      within(page.find(:css, 'div.list-group-item', text: 'Disqus')) do
        page.find(:css, 'i.bi-trash3-fill').click
      end
    end

    within(page.find(:css, 'div.list-group-item', text: 'Disqus')) do
      expect(page).to have_selector(:css, 'i.bi-plus-lg')
    end
  end

  it 'allows the user to add users to brand' do
    external_user = create(:user)
    find('#settings').click
    click_link 'Brand settings'

    select external_user.name, from: 'add-user'
    click_button 'Add'

    within(page.find('h6', text: 'Users in Brand').find(:xpath, '..')) do
      expect(page).to have_selector(:css, 'i.bi-trash3-fill')
    end
  end

  it 'allows the user to remove users from brand' do
    existing_user = create(:user, brand:)
    find('#settings').click
    click_link 'Brand settings'

    within(page.find('h6', text: 'Users in Brand').find(:xpath, '..')) do
      within(page.find(:css, 'div.list-group-item', text: existing_user.name)) do
        page.find(:css, 'i.bi-trash3-fill').click
      end
    end

    expect(page).to have_select('add-user', with_options: [existing_user.name])
  end

  it 'allows the user to edit the brand domain' do
    find('#settings').click
    click_link 'Brand settings'

    fill_in 'brand[domain]', with: 'example.com'
    click_button 'Update'

    expect(page).to have_field('brand[domain]', with: 'example.com')
  end

  it 'prevents the user to update the brand with an invalid domain' do
    find('#settings').click
    click_link 'Brand settings'

    fill_in 'brand[domain]', with: 'invalid!domain.com'
    click_button 'Update'

    expect(page).to have_field('brand[domain]', with: '')
  end
end
