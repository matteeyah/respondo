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
    click_link 'Settings'
    click_link 'Brand settings'

    add_oauth_mock_for_brand(brand, create(:brand_account, provider: 'disqus'))
    click_button 'Authorize Disqus'

    expect(page).to have_button('Remove Disqus')
  end

  it 'allows the user to remove an account' do
    create(:brand_account, provider: 'disqus', brand:)
    click_link 'Settings'
    click_link 'Brand settings'

    click_button 'Remove Disqus'

    expect(page).to have_button('Authorize Disqus')
  end

  it 'allows the user to add users to brand' do
    external_user = create(:user)
    click_link 'Settings'
    click_link 'Brand settings'

    select external_user.name, from: 'add-user'
    click_button 'Add User'

    expect(page).to have_button("Remove #{external_user.name}")
  end

  it 'allows the user to remove users from brand' do
    existing_user = create(:user, brand:)
    click_link 'Settings'
    click_link 'Brand settings'

    click_button "Remove #{existing_user.name}"

    expect(page).to have_select('add-user', with_options: [existing_user.name])
  end

  it 'allows the user to edit the brand domain' do
    click_link 'Settings'
    click_link 'Brand settings'

    fill_in 'brand[domain]', with: 'example.com'
    click_button 'Update'

    expect(page).to have_field('brand[domain]', with: 'example.com')
  end

  it 'prevents the user to update the brand with an invalid domain' do
    click_link 'Settings'
    click_link 'Brand settings'

    fill_in 'brand[domain]', with: 'invalid!domain.com'
    click_button 'Update'

    expect(page).to have_field('brand[domain]', with: '')
  end
end
