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

    add_oauth_mock(:google_oauth2, '123', { name: 'Test User', email: 'test@example.com' }, {})
    click_link('Login')

    expect(page).to have_link('Authorize Brand')

    add_oauth_mock(:twitter, '123', { nickname: 'test_brand' }, {})
    click_link('Authorize Brand')

    expect(page).to have_link('Brand Tickets')

    click_link('(logout)')

    expect(page).to have_link('Login')
  end
end
