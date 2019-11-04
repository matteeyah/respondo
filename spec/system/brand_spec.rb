# frozen_string_literal: true

require './spec/support/omniauth_helpers.rb'

RSpec.describe 'Brand', type: :system do
  include OmniauthHelpers

  let(:brand) { FactoryBot.create(:brand) }
  let!(:tickets) { FactoryBot.create_list(:ticket, 2, brand: brand) }

  before do
    visit brand_tickets_path(brand)
  end

  it 'shows tickets' do
    expect(page).to have_text(tickets.first.content)
    expect(page).to have_text(tickets.first.author.username)

    expect(page).to have_text(tickets.second.content)
    expect(page).to have_text(tickets.second.author.username)
  end

  it 'allows solving tickets' do
    login_user
    login_brand(brand)

    within('ul.list-group > li.list-group-item:first-child') do
      click_button 'Solve'
    end

    click_link 'Solved Tickets'

    expect(page).to have_text(tickets.first.author.username)
    expect(page).to have_text(tickets.first.content)
  end

  it 'allows replying to tickets' do
    brand.update(token: 'hello', secret: 'world')

    login_user
    login_brand(brand)

    response_text = 'Hello from Respondo system tests'
    stub_twitter_reply_response(
      brand.external_uid,
      brand.screen_name,
      tickets.first.external_uid,
      response_text
    )

    within('ul.list-group > li.list-group-item:first-child') do
      fill_in :response_text, with: response_text
      click_button 'Reply'
    end

    within('ul.list-group > li.list-group-item:first-child > ul') do
      expect(page).to have_text(brand.screen_name)
      expect(page).to have_text(response_text)
    end
  end

  it 'allows replying to tickets from other brands' do
    user = login_user
    account = FactoryBot.create(:account, provider: 'twitter', token: 'hello', secret: 'world', user: user)
    page.driver.browser.navigate.refresh

    response_text = 'Hello from Respondo system tests'
    user_nickname = 'test_nickname'
    stub_twitter_reply_response(
      account.external_uid,
      user_nickname,
      brand.tickets.first.external_uid,
      response_text
    )

    within('ul.list-group > li.list-group-item:first-child') do
      fill_in :response_text, with: response_text
      click_button 'Reply'
    end

    within('ul.list-group > li.list-group-item:first-child > ul') do
      expect(page).to have_text(user_nickname)
      expect(page).to have_text(response_text)
    end
  end

  private

  def stub_twitter_reply_response(user_external_uid, user_screen_name, in_reply_to_status_id, response_text)
    response = {
      id: 123456,
      user: { id: user_external_uid, screen_name: user_screen_name },
      in_reply_to_status_id: in_reply_to_status_id,
      full_text: response_text
    }
    stub_request(:post, "https://api.twitter.com/1.1/statuses/update.json")
      .to_return(status: 200, body: response.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  def login_user(user = nil)
    (user || FactoryBot.create(:user, :with_account)).tap do |user|
      add_oauth_mock_for_user(user)
      click_link 'Login User'
    end
  end

  def login_brand(brand = nil)
    (brand || FactoryBot.create(:brand)).tap do |brand|
      add_oauth_mock_for_brand(brand)
      click_link 'Login Brand'
    end
  end
end
