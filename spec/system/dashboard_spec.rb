# frozen_string_literal: true

require './spec/support/sign_in_out_system_helpers'
require './spec/support/system/allows_interacting_with_tickets_examples'

RSpec.describe 'Dashboard', type: :system do
  include SignInOutSystemHelpers

  let(:brand) { create(:brand, :with_account) }
  let!(:tickets) { create_list(:internal_ticket, 2, brand:).map(&:base_ticket) }

  before do
    create(:subscription, brand:)

    visit '/'
  end

  it 'shows the newest tickets' do
    sign_in_user
    sign_in_brand(brand)
    click_link('Dashboard')

    expect(page).to have_text(tickets.first&.content)
    expect(page).to have_text(tickets.first&.author&.username)

    expect(page).to have_text(tickets.second&.content)
    expect(page).to have_text(tickets.second&.author&.username)
  end

  it 'shows the tickets info widgets' do
    sign_in_user
    sign_in_brand(brand)
    click_link('Dashboard')

    expect(page).to have_text('Feel free to hop into the brand tickets!')

    expect(page).to have_text('New Tickets')
    expect(page).to have_text(tickets.count)

    expect(page).to have_text('Total Open')
    expect(page).to have_text(tickets&.select { |e| e.status == 'open' }&.count)
  end

  it 'allows show all tickets with home widget' do
    sign_in_user
    sign_in_brand(brand)
    click_link('Dashboard')

    expect(page).to have_text('New Tickets')
    click_link('New Tickets')

    expect(page).to have_text(tickets.first.content)
    expect(page).to have_text(tickets.second.content)
  end
end
