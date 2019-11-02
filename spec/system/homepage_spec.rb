# frozen_string_literal: true

require './spec/support/omniauth_helpers.rb'

RSpec.describe 'Homepage', type: :system do
  include OmniauthHelpers

  it 'guides user through the set-up process' do
    visit '/'

    expect(page).to have_text('Hello, world!')
    expect(page).to have_link('Login')

    user = FactoryBot.create(:user, :with_account)
    add_oauth_mock_for_user(user)
    click_link('Login')

    expect(page).to have_link('Authorize Brand')

    brand = FactoryBot.create(:brand)
    add_oauth_mock_for_brand(brand)
    click_link('Authorize Brand')

    expect(page).to have_link('Brand Tickets')

    click_link('(logout)')

    expect(page).to have_link('Login')
  end
end
