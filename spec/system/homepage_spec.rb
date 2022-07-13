# frozen_string_literal: true

require './spec/support/sign_in_out_system_helpers'
require './spec/support/omniauth_helpers'

RSpec.describe 'Homepage', type: :system do
  include SignInOutSystemHelpers
  include OmniauthHelpers

  let(:brand) { create(:brand, :with_account) }

  before do
    create(:subscription, brand:)

    visit '/'
  end

  it 'guides user through the set-up process' do
    expect(page).to have_button('Sign in with Google')

    add_oauth_mock_for_user(create(:user, :with_account))
    click_button('Sign in with Google')

    expect(page).to have_button('Authorize Brand', class: 'btn')

    add_oauth_mock_for_brand(create(:brand, :with_account))
    click_button('Authorize Brand', class: 'btn btn-primary')

    find('#settings').click
    click_button('Sign Out')
    expect(page).to have_button('Sign in with Google')
  end

  it 'shows the login page' do
    expect(page).to have_text('Sign in')
  end
end
