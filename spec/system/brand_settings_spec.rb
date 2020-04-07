# frozen_string_literal: true

require './spec/support/omniauth_helpers.rb'
require './spec/support/sign_in_out_system_helpers.rb'

RSpec.describe 'Brand settings', type: :system do
  include OmniauthHelpers
  include SignInOutSystemHelpers

  let!(:brand) { FactoryBot.create(:brand, :with_account) }

  before do
    visit '/'

    sign_in_user
    sign_in_brand(brand)

    click_link 'Brand settings'
  end

  it 'allows the user to authorize an account' do
    add_oauth_mock_for_brand(brand, FactoryBot.create(:brand_account, provider: 'disqus'))
    click_link('Authorize Disqus', wait: 10)

    expect(page).to have_link('Remove Disqus')
  end

  it 'allows the user to remove an account' do
    FactoryBot.create(:brand_account, provider: 'disqus', brand: brand)
    click_link 'Remove Disqus'

    expect(page).to have_link('Authorize Disqus')
  end

  it 'allows the user to add users to brand' do
    external_user = FactoryBot.create(:user)

    select(external_user.name, from: 'add-user', wait: 10)
    click_button 'Add User'

    expect(page).to have_link("Remove #{external_user.name}")
  end

  it 'allows the user to remove users from brand' do
    existing_user = FactoryBot.create(:user, brand: brand)

    click_link("Remove #{existing_user.name}", wait: 10)

    expect(page).to have_select('add-user', with_options: [existing_user.name])
  end

  it 'allows the user to edit the brand domain' do
    fill_in 'brand[domain]', with: 'example.com'
    click_button 'Update domain'

    expect(page).to have_field('brand[domain]', with: 'example.com')
  end

  it 'prevents the user to update the brand with an invalid domain' do
    fill_in 'brand[domain]', with: 'invalid!domain.com'
    click_button 'Update domain'

    expect(page).to have_field('brand[domain]', with: '')
  end
end
