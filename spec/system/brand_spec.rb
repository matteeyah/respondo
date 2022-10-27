# frozen_string_literal: true

require './spec/support/sign_in_out_system_helpers'
require './spec/support/system/allows_interacting_with_tickets_examples'

RSpec.describe 'Brand' do
  include SignInOutSystemHelpers

  let(:brand) { create(:brand, :with_account) }
  let!(:tickets) { create_list(:internal_ticket, 2, brand:, source: brand.accounts.first).map(&:base_ticket) }

  before do
    create(:subscription, brand:)

    visit '/'
  end

  it 'shows the tickets' do
    user = create(:user, :with_account, brand:)
    sign_in_user(user)
    click_link('Brand Tickets')

    expect(page).to have_text(tickets.first.content)
    expect(page).to have_text(tickets.first.author.username)

    expect(page).to have_text(tickets.second.content)
    expect(page).to have_text(tickets.second.author.username)
  end

  include_examples 'allows interacting with tickets' do
    let(:target_ticket) { tickets.first }
  end

  it 'allows navigating to tickets' do
    sign_in_user
    sign_in_brand(brand)
    click_link('Brand Tickets')

    target_ticket = tickets.first

    within("#ticket_#{target_ticket.id}") do
      page.find(:css, 'i.bi-bullseye').click
    end

    expect(page).to have_text(target_ticket.content)
  end

  describe 'Search' do
    it 'allows searching tickets by author name' do
      sign_in_user
      sign_in_brand(brand)
      click_link('Brand Tickets')

      fill_in 'query', with: tickets.first.author.username
      click_button 'Search'

      expect(page).to have_text(tickets.first.content)
      expect(page).not_to have_text(tickets.second.content)
    end

    it 'allows searching tickets by content' do
      sign_in_user
      sign_in_brand(brand)
      click_link('Brand Tickets')

      fill_in 'query', with: tickets.first.content
      click_button 'Search'

      expect(page).to have_text(tickets.first.content)
      expect(page).not_to have_text(tickets.second.content)
    end

    it 'keeps ticket status context when searching' do
      solved_tickets = create_list(:internal_ticket, 2, status: :solved, brand:).map(&:base_ticket)
      tickets.first.update!(content: solved_tickets.first.content)

      sign_in_user
      sign_in_brand(brand)
      click_link('Brand Tickets')

      click_link 'Solved'

      # This is a hack to make Capybara wait until the page is loaded after navigating
      find(:xpath, "//input[@type='hidden'][@value='solved']", visible: :hidden)

      fill_in 'query', with: solved_tickets.first.content
      click_button 'Search'

      expect(page).to have_text(solved_tickets.first.author.username)
      expect(page).not_to have_text(solved_tickets.second.author.username)
      expect(page).not_to have_text(tickets.first.author.username)
      expect(page).not_to have_text(tickets.second.author.username)
    end

    it 'allows searching by nested ticket content' do
      nested_ticket = create(:internal_ticket, brand:, parent: tickets.first).base_ticket
      nested_nested_ticket = create(:internal_ticket, brand:, parent: nested_ticket).base_ticket

      sign_in_user
      sign_in_brand(brand)
      click_link('Brand Tickets')

      fill_in 'query', with: nested_ticket.content
      click_button 'Search'

      expect(page).to have_text(nested_ticket.content)
      expect(page).to have_text(nested_nested_ticket.content)
      expect(page).not_to have_text(tickets.first.content)
      expect(page).not_to have_text(tickets.second.content)
    end
  end
end
