# frozen_string_literal: true

require './spec/support/omniauth_helpers'

RSpec.describe 'Homepage', type: :system do
  include OmniauthHelpers

  it 'guides user through the set-up process' do
    visit '/'

    expect(page).to have_text('Hello, world!')
    expect(page).to have_link('Sign In')

    add_oauth_mock_for_user(FactoryBot.create(:user, :with_account))
    click_link('Sign In', class: 'btn')

    expect(page).to have_link('Authorize Brand')

    add_oauth_mock_for_brand(FactoryBot.create(:brand, :with_account))
    click_link('Authorize Brand', class: 'btn')

    expect(page).to have_link('Brand Tickets')

    click_link('(sign out)')

    expect(page).to have_link('Sign In')
  end
end
