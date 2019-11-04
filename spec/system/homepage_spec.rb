# frozen_string_literal: true

require './spec/support/sign_in_out_system_helpers.rb'

RSpec.describe 'Homepage', type: :system do
  include SignInOutSystemHelpers

  it 'guides user through the set-up process' do
    visit '/'

    expect(page).to have_text('Hello, world!')
    expect(page).to have_link('Login')

    sign_in_user(nil, 'Login')

    expect(page).to have_link('Authorize Brand')

    sign_in_brand(nil, 'Authorize Brand')

    expect(page).to have_link('Brand Tickets')

    click_link('(logout)')

    expect(page).to have_link('Login')
  end
end
