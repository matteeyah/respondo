# frozen_string_literal: true

require './spec/support/sign_in_out_system_helpers'
require './spec/support/system/allows_interacting_with_tickets_examples'

RSpec.describe 'Brand', type: :system do
  include SignInOutSystemHelpers

  let(:brand) { create(:brand, :with_account) }
  let!(:tickets) { create_list(:internal_ticket, 2, brand:).map(&:base_ticket) }

  before do
    create(:subscription, brand:)

    visit '/'
  end

  it 'shows the tickets' do
    user = create(:user, :with_account, brand:)
    sign_in_user(user)
    click_link('Tickets')

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
    click_link('Tickets')

    target_ticket = tickets.first

    within('ul.list-group > li.list-group-item:first-child') do
      find(:css, "a[href='#{brand_ticket_path(brand, target_ticket)}']").click
    end

    expect(page).to have_current_path(brand_ticket_path(brand, target_ticket))
  end

  describe 'Search' do
    it 'allows searching tickets by author name' do
      sign_in_user
      sign_in_brand(brand)
      click_link('Tickets')

      fill_in 'query', with: tickets.first.author.username
      click_button 'Search'

      expect(page).to have_text(tickets.first.content)
      expect(page).not_to have_text(tickets.second.content)
    end

    it 'allows searching tickets by content' do
      sign_in_user
      sign_in_brand(brand)
      click_link('Tickets')

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
      click_link('Tickets')

      click_link 'Solved Tickets'

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
      click_link('Tickets')

      fill_in 'query', with: nested_ticket.content
      click_button 'Search'

      expect(page).to have_text(nested_ticket.content)
      expect(page).to have_text(nested_nested_ticket.content)
      expect(page).not_to have_text(tickets.first.content)
      expect(page).not_to have_text(tickets.second.content)
    end
  end

  private

  def stub_twitter_reply_response(user_external_uid, user_screen_name, in_reply_to_status_id, response_text)
    stub_request(:post, 'https://api.twitter.com/oauth2/token')
      .to_return(status: 200, body: '{}', headers: { 'Content-Type' => 'application/json' })

    response = {
      id: 123_456,
      user: { id: user_external_uid, screen_name: user_screen_name },
      in_reply_to_status_id:,
      full_text: response_text
    }
    stub_request(:post, 'https://api.twitter.com/1.1/statuses/update.json')
      .to_return(status: 200, body: response.to_json, headers: { 'Content-Type' => 'application/json' })
  end
end
