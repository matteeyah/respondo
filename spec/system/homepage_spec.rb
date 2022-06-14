# frozen_string_literal: true

require './spec/support/omniauth_helpers'

RSpec.describe 'Homepage', type: :system do
  include OmniauthHelpers

  it 'guides user through the set-up process' do
    visit '/'

    expect(page).to have_text('Hello, world!')
    expect(page).to have_button('Sign In')

    add_oauth_mock_for_user(create(:user, :with_account))
    click_button('Sign In', class: 'btn')

    expect(page).to have_button('Authorize Brand')

    add_oauth_mock_for_brand(create(:brand, :with_account))
    click_button('Authorize Brand', class: 'btn')

    expect(page).to have_link('Brand Tickets')

    click_button('(sign out)')

    expect(page).to have_button('Sign In')
  end
end
