# frozen_string_literal: true

require './spec/support/omniauth_helpers.rb'
require './spec/support/sign_in_out_system_helpers.rb'

RSpec.describe 'Brand settings', type: :system do
  include OmniauthHelpers
  include SignInOutSystemHelpers

  let(:brand) { FactoryBot.create(:brand, :with_account) }

  before do
    visit '/'

    sign_in_user
    sign_in_brand(brand)

    click_link 'Brand settings'
  end

  it 'allows the user to authorize an account' do
    add_oauth_mock_for_brand(brand, FactoryBot.create(:brand_account, provider: 'disqus'))
    click_link 'Authorize Disqus'

    expect(page).to have_link('Remove Disqus')
  end

  it 'allows the user to remove an account' do
    FactoryBot.create(:brand_account, provider: 'disqus', brand: brand)
    click_link 'Remove Disqus'

    expect(page).to have_link('Authorize Disqus')
  end

  context 'when adding users to brand' do
    let!(:external_user) { FactoryBot.create(:user) }

    it 'allows the user to add users to brand' do
      select external_user.name, from: 'add-user'
      click_button 'Add User'

      expect(page).to have_link("Remove #{external_user.name}")
    end
  end

  context 'when removing user from brand' do
    let!(:existing_user) { FactoryBot.create(:user, brand: brand) }

    it 'allows the user to remove users from brand' do
      click_link "Remove #{existing_user.name}"

      expect(page).to have_select('add-user', with_options: [existing_user.name])
    end
  end
end
