# frozen_string_literal: true

require './spec/support/omniauth_helpers.rb'

RSpec.describe 'User settings', type: :system do
  include OmniauthHelpers

  let(:user) { FactoryBot.create(:user, :with_account) }
  let(:brand) { FactoryBot.create(:brand) }

  before do
    add_oauth_mock_for_user(user, user.accounts.first)
    add_oauth_mock_for_brand(brand)

    visit '/'

    click_link 'Login User'
    click_link 'Login Brand'
    click_link 'User settings'
  end

  after do
    OmniAuth.config.mock_auth.slice!(:default)
  end

  context 'when adding accounts to user' do
    before do
      add_oauth_mock('twitter', '123', { name: user.name, email: 'hello@world.com' }, {})
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
