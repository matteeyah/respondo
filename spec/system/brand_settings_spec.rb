# frozen_string_literal: true

require './spec/support/sign_in_out_system_helpers.rb'

RSpec.describe 'Brand settings', type: :system do
  include SignInOutSystemHelpers

  let(:brand) { FactoryBot.create(:brand) }

  before do
    visit '/'

    sign_in_user
    sign_in_brand(brand)

    click_link 'Brand settings'
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
