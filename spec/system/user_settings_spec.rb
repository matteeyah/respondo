# frozen_string_literal: true

require './spec/support/omniauth_helpers.rb'

RSpec.describe 'User settings', type: :system do
  include OmniauthHelpers

  let(:user) { FactoryBot.create(:user, :with_account) }

  before do
    add_oauth_mock_for_user(user)

    visit '/'

    click_link 'Login User'
    click_link 'User settings'
  end

  context 'when adding accounts to user' do
    before do
      add_oauth_mock_for_user(user, FactoryBot.create(:account, provider: 'twitter'))
    end

    it 'allows the user to authorize an account' do
      click_link 'Authorize Twitter'

      expect(page).to have_link('Remove Twitter')
    end
  end

  context 'when removing accounts from user' do
    before do
      FactoryBot.create(:account, provider: 'twitter', user: user)
    end

    it 'allows the user to remove an account' do
      click_link 'Remove Twitter'

      expect(page).to have_link('Authorize Twitter')
    end
  end
end
