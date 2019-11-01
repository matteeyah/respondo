# frozen_string_literal: true

require './spec/support/omniauth_helpers.rb'

RSpec.describe 'Homepage', type: :system do
  include OmniauthHelpers

  after do
    OmniAuth.config.mock_auth.slice!(:default)
  end

  it 'guides user through the set-up process' do
    visit '/'

    expect(page).to have_text('Hello, world!')
    expect(page).to have_link('Login')

    add_user_oauth_mock('google_oauth2', '123', 'Test User', 'test@example.com')
    click_link('Login')

    expect(page).to have_link('Authorize Brand')

    add_brand_oauth_mock('twitter', '123', 'test_brand', 'hello', 'world')
    click_link('Authorize Brand')

    expect(page).to have_link('Brand Tickets')
  end
end
