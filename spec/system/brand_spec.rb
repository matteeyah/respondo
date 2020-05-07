# frozen_string_literal: true

require './spec/support/sign_in_out_system_helpers.rb'
require './spec/support/system/allows_interacting_with_tickets_examples.rb'

RSpec.describe 'Brand', type: :system do
  include SignInOutSystemHelpers

  let(:brand) { FactoryBot.create(:brand, :with_account) }
  let!(:tickets) { FactoryBot.create_list(:ticket, 2, brand: brand) }

  before do
    FactoryBot.create(:subscription, brand: brand)

    visit brand_tickets_path(brand)
  end

  it 'shows the tickets' do
    expect(page).to have_text(tickets.first.content)
    expect(page).to have_text(tickets.first.author.username)

    expect(page).to have_text(tickets.second.content)
    expect(page).to have_text(tickets.second.author.username)
  end

  include_examples 'allows interacting with tickets' do
    let(:target_ticket) { tickets.first }
  end

  it 'allows replying to tickets from other brands' do
    user = sign_in_user
    account = FactoryBot.create(:user_account, provider: 'twitter', token: 'hello', secret: 'world', user: user)
    page.driver.browser.navigate.refresh

    target_ticket = tickets.first
    response_text = 'Hello from Respondo system tests'
    user_nickname = 'test_nickname'
    stub_twitter_reply_response(
      account.external_uid,
      user_nickname,
      target_ticket.external_uid,
      response_text
    )

    click_button "toggle-reply-#{target_ticket.id}"

    within "form[action='#{brand_ticket_reply_path(target_ticket.brand, target_ticket)}']" do
      fill_in :response_text, with: response_text
      click_button 'Reply'
    end

    within('ul.list-group > li.list-group-item:first-child > ul') do
      expect(page).to have_text(user_nickname)
      expect(page).to have_text(response_text)
    end
  end

  it 'allows navigating to tickets' do
    sign_in_user
    sign_in_brand(brand)

    target_ticket = tickets.first

    within('ul.list-group > li.list-group-item:first-child') do
      click_link target_ticket.created_at.to_formatted_s(:short)
    end

    expect(page).to have_current_path(brand_ticket_path(brand, target_ticket))
  end

  describe 'Search' do
    it 'allows searching tickets by author name' do
      sign_in_user
      sign_in_brand(brand)

      fill_in :query, with: tickets.first.author.username
      click_button 'Search'

      expect(page).to have_text(tickets.first.content)
      expect(page).not_to have_text(tickets.second.content)
    end

    it 'allows searching tickets by content' do
      sign_in_user
      sign_in_brand(brand)

      fill_in :query, with: tickets.first.content
      click_button 'Search'

      expect(page).to have_text(tickets.first.content)
      expect(page).not_to have_text(tickets.second.content)
    end

    it 'keeps ticket status context when searching' do
      solved_tickets = FactoryBot.create_list(:ticket, 2, status: :solved, brand: brand)
      tickets.first.update(content: solved_tickets.first.content)

      sign_in_user
      sign_in_brand(brand)

      click_link 'Solved Tickets'

      # This is a hack to make Capybara wait until the page is loaded after navigating
      find(:xpath, "//input[@type='hidden'][@value='solved']", visible: :hidden)

      fill_in :query, with: solved_tickets.first.content
      click_button 'Search'

      expect(page).to have_text(solved_tickets.first.author.username)
      expect(page).not_to have_text(solved_tickets.second.author.username)
      expect(page).not_to have_text(tickets.first.author.username)
      expect(page).not_to have_text(tickets.second.author.username)
    end

    it 'allows searching by nested ticket content' do
      nested_ticket = FactoryBot.create(:ticket, brand: brand, parent: tickets.first)
      nested_nested_ticket = FactoryBot.create(:ticket, brand: brand, parent: nested_ticket)

      sign_in_user
      sign_in_brand(brand)

      fill_in :query, with: nested_ticket.content
      click_button 'Search'

      expect(page).to have_text(nested_ticket.content)
      expect(page).to have_text(nested_nested_ticket.content)
      expect(page).not_to have_text(tickets.first.content)
      expect(page).not_to have_text(tickets.second.content)
    end
  end

  private

  def stub_twitter_reply_response(user_external_uid, user_screen_name, in_reply_to_status_id, response_text)
    response = {
      id: 123_456,
      user: { id: user_external_uid, screen_name: user_screen_name },
      in_reply_to_status_id: in_reply_to_status_id,
      full_text: response_text
    }
    stub_request(:post, 'https://api.twitter.com/1.1/statuses/update.json')
      .to_return(status: 200, body: response.to_json, headers: { 'Content-Type' => 'application/json' })
  end
end
