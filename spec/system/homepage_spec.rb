# frozen_string_literal: true

require './spec/support/sign_in_out_system_helpers'
require './spec/support/omniauth_helpers'

RSpec.describe 'Homepage', type: :system do
  include SignInOutSystemHelpers
  include OmniauthHelpers

  let(:brand) { create(:brand, :with_account) }
  let!(:tickets) { create_list(:internal_ticket, 2, brand:).map(&:base_ticket) }

  before do
    create(:subscription, brand:)

    visit '/'
  end

  it 'guides user through the set-up process' do
    visit '/'

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

  it 'shows the newest tickets' do
    user = create(:user, :with_account, brand:)
    sign_in_user(user)

    expect(page).to have_text(tickets.first&.content)
    expect(page).to have_text(tickets.first&.author&.username)

    expect(page).to have_text(tickets.second&.content)
    expect(page).to have_text(tickets.second&.author&.username)
  end

  it 'shows the tickets info widgets' do
    user = create(:user, :with_account, brand:)
    sign_in_user(user)

    expect(page).to have_text('Feel free to hop into the brand tickets!')

    expect(page).to have_text('New Tickets')
    expect(page).to have_text(tickets&.count)

    expect(page).to have_text('Total Open')
    expect(page).to have_text(tickets&.select { |e| e.status == 'open' }&.count)
  end

  it 'allows show all tickets with home widget' do
    sign_in_user
    sign_in_brand(brand)
    click_link('New Tickets')

    expect(page).to have_text(tickets.first.content)
    expect(page).to have_text(tickets.second.content)
  end

  it 'shows the login page' do
    visit '/'

    expect(page).to have_text('Sign in')
  end
end
