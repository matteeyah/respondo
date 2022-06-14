# frozen_string_literal: true

require './spec/support/omniauth_helpers'
require './spec/support/sign_in_out_system_helpers'

RSpec.describe 'Authentication', type: :system do
  include OmniauthHelpers
  include SignInOutSystemHelpers

  it 'allows user creation' do
    visit '/'

    add_oauth_mock(:google_oauth2, '123', { name: 'Test User', email: 'test@example.com' }, {})
    click_button('Sign In', class: 'nav-link')
    expect(page).to have_link('User settings')
  end

  context 'when user email belongs to brand domain' do
    before do
      create(:brand, domain: 'example.com')
    end

    it 'adds the user to the brand' do
      visit '/'

      add_oauth_mock(:google_oauth2, '123', { name: 'Test User', email: 'test@example.com' }, {})
      click_button('Sign In', class: 'nav-link')
      expect(page).to have_link('Tickets')
    end
  end

  it 'redirects after sign in' do
    brand = create(:brand)

    visit brand_tickets_path(brand)

    sign_in_user
    expect(page).to have_current_path(brand_tickets_path(brand))
  end

  it 'allows brand creation' do
    visit '/'

    sign_in_user

    add_oauth_mock(:twitter, '123', { nickname: 'test_brand' }, {})
    click_button('Authorize Brand', class: 'nav-link')
    expect(page).to have_link('Brand settings')
  end

  it 'allows signing out' do
    visit '/'

    sign_in_user
    click_link('User settings')

    click_button('(sign out)')
    expect(page).to have_current_path(root_path)
  end
end
