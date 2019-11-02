# frozen_string_literal: true

require './spec/support/omniauth_helpers.rb'

RSpec.describe 'Homepage', type: :system do
  include OmniauthHelpers

  it 'allows user creation' do
    visit '/'

    add_oauth_mock(:google_oauth2, '123', { name: 'Test User', email: 'test@example.com' }, {})
    click_link('Login')
    expect(page).to have_link('User settings')
  end

  it 'redirects after login' do
    user = FactoryBot.create(:user, :with_account)
    add_oauth_mock_for_user(user)

    visit brands_path

    click_link('Login')
    expect(page).to have_current_path(brands_path)
  end

  it 'allows brand creation' do
    visit '/'

    user = FactoryBot.create(:user, :with_account)
    add_oauth_mock_for_user(user)

    click_link('Login')

    add_oauth_mock(:twitter, '123', { nickname: 'test_brand' }, {})
    click_link('Authorize Brand')
    expect(page).to have_link('Brand settings')
  end

  it 'allows logging out' do
    visit '/'

    user = FactoryBot.create(:user, :with_account)
    add_oauth_mock_for_user(user)

    click_link('Login')
    click_link('User settings')

    click_link('(logout)')
    expect(page).to have_current_path(root_path)
  end
end
