# frozen_string_literal: true

require 'application_system_test_case'

require 'support/authentication_helper'

class TicketTest < ApplicationSystemTestCase
  include AuthenticationHelper

  def setup
    @user = users(:john)
    @brand = brands(:respondo)
    @ticket = tickets(:internal_twitter)

    Subscription.create!(external_uid: 'uid_1', status: 'active', email: 'hello@respondo.com', brand: @brand,
                         cancel_url: 'https://respondo.com/cancel', update_url: 'https://respondo.com/update')

    visit '/'

    sign_in_user(@user)
    sign_in_brand(@brand)
    click_link('Tickets')
  end

  test 'shows the ticket' do
    assert has_text?(@ticket.content)
    assert has_text?(@ticket.author.username)
  end

  test 'allows replying to ticket' do
    account = @ticket.source
    account.update!(token: 'hello', secret: 'world')

    response_text = 'Hello from Respondo system tests'
    stub_twitter_reply_response(
      account.external_uid,
      @brand.screen_name,
      @ticket.external_uid,
      response_text
    )

    click_link "toggle-reply-#{@ticket.id}"

    fill_in 'ticket[content]', with: response_text
    click_button 'Reply'

    assert has_text?("#{@user.name} as #{@brand.screen_name}")
    assert has_text?(response_text)
  end

  test 'allows replying to external tickets' do
    response_text = 'Hello from Respondo system tests'
    external_ticket = tickets(:external)
    response = {
      external_uid: 123_456,
      author: { external_uid: '123', username: @brand.screen_name },
      response_url: external_ticket.ticketable.response_url,
      parent_uid: external_ticket.external_uid,
      content: response_text
    }
    stub_request(:post, external_ticket.ticketable.response_url)
      .to_return(status: 200, body: response.to_json, headers: { 'Content-Type' => 'application/json' })

    click_link "toggle-reply-#{external_ticket.id}"

    fill_in 'ticket[content]', with: response_text
    click_button 'Reply'

    assert has_text?("#{@user.name} as #{@brand.screen_name}")
    assert has_text?(response_text)
  end

  test 'allows leaving internal notes on tickets' do
    internal_note_text = 'Internal note from Respondo system tests.'

    click_link "toggle-internal-note-#{@ticket.id}"

    fill_in 'internal_note[content]', with: internal_note_text
    click_button 'Create note'

    within("#ticket_#{@ticket.id}_internal_notes") do
      assert has_text?(@user.name)
      assert has_text?(internal_note_text)
    end
  end

  test 'allows solving tickets' do
    within("#ticket_#{@ticket.id}") do
      click_link "toggle-status-#{@ticket.id}"
      select 'solved', from: 'ticket-status'
      click_button 'Update'
    end

    click_link 'Solved'

    assert has_text?(@ticket.author.username)
    assert has_text?(@ticket.content)
  end

  test 'allows adding ticket tags' do
    within("#ticket_#{@ticket.id}") do
      click_link "toggle-tag-#{@ticket.id}"
      fill_in :'acts_as_taggable_on_tag[name]', with: 'hello'
      click_button 'Tag ticket'
    end

    within("#ticket_#{@ticket.id}") do
      assert has_selector?(:css, 'span', text: 'hello')
    end
  end

  test 'allows removing ticket tags' do
    @ticket.update(tag_list: 'hello, world')

    within("#ticket_#{@ticket.id}") do
      within('span', text: 'hello') do
        page.find(:css, 'i.bi-x').click
      end
    end

    within("#ticket_#{@ticket.id}") do
      assert has_no_selector?(:css, 'span', text: 'hello')
      assert has_selector?(:css, 'span', text: 'world')
    end
  end

  test 'allows updating ticket assignment' do
    within("#ticket_#{@ticket.id}") do
      click_link "toggle-assign-#{@ticket.id}"
      select @user.name, from: 'ticket-assignment'
      click_button 'Assign'
    end

    assert has_text?(@user.name)
  end

  test 'allows deleting tickets' do
    @ticket.update!(creator: @user)
    @ticket.source.update!(token: 'hello', secret: 'world')
    stub_request(:post, 'https://api.twitter.com/1.1/statuses/destroy/0.json')
      .to_return(status: 200, body: { id: 'world' }.to_json, headers: { content_type: 'application/json' })

    within("#ticket_#{@ticket.id}") do
      page.find_link("delete-#{@ticket.id}").click
    end

    assert has_no_text?(@ticket.content)
  end

  test 'allows navigating to tickets externally' do
    @ticket.source.update!(token: 'hello', secret: 'world')
    stub_request(:get, 'https://api.twitter.com/1.1/statuses/show/0.json').to_return(
      status: 200,
      body: { id: 1, user: { id: 2, screen_name: 'hello' } }.to_json,
      headers: { content_type: 'application/json' }
    )

    within("#ticket_#{@ticket.id}") do
      click_link "permalink-#{@ticket.id}"
    end

    assert_current_path('https://twitter.com/hello/status/1')
  end

  private

  def stub_twitter_reply_response(user_external_uid, user_screen_name, in_reply_to_status_id, response_text)
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
