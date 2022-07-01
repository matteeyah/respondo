# frozen_string_literal: true

require './spec/support/omniauth_helpers'
require './spec/support/sign_in_out_system_helpers'

RSpec.describe 'Authentication', type: :system do
  include OmniauthHelpers
  include SignInOutSystemHelpers

  it 'allows user creation' do
    visit '/'

    add_oauth_mock(:google_oauth2, '123', { name: 'Test User', email: 'test@example.com' }, {})
    click_button('Sign in with Google')
    find('#settings').click
    expect(page).to have_link('User settings')
  end

  context 'when user email belongs to brand domain' do
    before do
      create(:brand, domain: 'example.com')
    end

    it 'adds the user to the brand' do
      visit '/'

      add_oauth_mock(:google_oauth2, '123', { name: 'Test User', email: 'test@example.com' }, {})
      click_button('Sign in with Google')
      expect(page).to have_link('Tickets')
    end
  end

  it 'allows brand creation' do
    visit '/'

    sign_in_user

    add_oauth_mock(:twitter, '123', { nickname: 'test_brand' }, {})
    click_button('Authorize Brand')
    find('#settings').click
    expect(page).to have_link('Brand settings')
  end

  it 'allows signing out' do
    visit '/'

    sign_in_user
    find('#settings').click
    click_button 'Sign Out'

    expect(page).to have_current_path(login_path)
  end
end
