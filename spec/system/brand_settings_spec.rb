# frozen_string_literal: true

require './spec/support/omniauth_helpers.rb'

RSpec.describe 'Brand settings', type: :system do
  include OmniauthHelpers

  let(:brand) { FactoryBot.create(:brand) }

  before do
    user = FactoryBot.create(:user, :with_account)
    add_oauth_mock_for_user(user, user.accounts.first)
    add_oauth_mock_for_brand(brand)

    visit '/'

    click_link 'Login User'
    click_link 'Login Brand'
    click_link 'Brand settings'
  end

  after do
    OmniAuth.config.mock_auth.slice!(:default)
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
