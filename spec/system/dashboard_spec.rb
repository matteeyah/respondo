# frozen_string_literal: true

require './spec/support/sign_in_out_system_helpers'

RSpec.describe 'Dashboard' do
  include SignInOutSystemHelpers

  let(:brand) { create(:brand, :with_account) }
  let!(:tickets) { create_list(:internal_ticket, 2, brand:).map(&:base_ticket) }

  it 'shows the newest tickets' do
    visit '/'

    sign_in_user
    sign_in_brand(brand)
    click_link('Dashboard')

    expect(page).to have_text(tickets.first.content)
    expect(page).to have_text(tickets.first.author.username)

    expect(page).to have_text(tickets.second.content)
    expect(page).to have_text(tickets.second.author.username)
  end

  it 'shows the tickets info widgets' do
    visit '/'

    sign_in_user
    sign_in_brand(brand)
    click_link('Dashboard')

    expect(page).to have_text('New Tickets')
    expect(page).to have_text(tickets.count)

    expect(page).to have_text('Total Open')
    expect(page).to have_text(tickets.count)
  end

  it 'allows show all tickets with home widget' do
    visit '/'

    sign_in_user
    sign_in_brand(brand)
    click_link('Dashboard')

    expect(page).to have_text('New Tickets')
    click_link('New Tickets')

    expect(page).to have_text(tickets.first.content)
    expect(page).to have_text(tickets.second.content)
  end
end
