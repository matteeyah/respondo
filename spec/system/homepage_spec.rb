# frozen_string_literal: true

require './spec/support/omniauth_helpers'

RSpec.describe 'Homepage' do
  include OmniauthHelpers

  it 'guides user through the set-up process' do
    visit '/'

    expect(page).to have_button('Sign in with Google')

    add_oauth_mock_for_user(create(:user, :with_account))
    click_button('Sign in with Google')

    expect(page).to have_button('Authorize Brand', class: 'btn')

    add_oauth_mock_for_brand(create(:brand, :with_account))
    click_button('Authorize Brand', class: 'btn btn-primary')

    find_by_id('settings').click
    click_button('Sign Out')
    expect(page).to have_button('Sign in with Google')
  end
end
