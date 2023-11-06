# frozen_string_literal: true

require 'application_system_test_case'

require 'support/authentication_helper'

class TicketTest < ApplicationSystemTestCase
  include AuthenticationHelper

  setup do
    @user = users(:john)
    @organization = organizations(:respondo)
    @ticket = tickets(:x)

    @user.update!(organization: @organization)
    sign_in(@user)
  end

  test 'shows the ticket' do
    visit tickets_path

    assert has_text?(@ticket.content)
    assert has_text?(@ticket.author.username)
  end

  test 'allows replying to ticket' do
    visit tickets_path

    account = @ticket.source
    account.update!(token: 'hello', secret: 'world')

    response_text = 'Hello from Respondo system tests'
    stub_x_reply_response(
      account.external_uid,
      @organization.screen_name,
      @ticket.external_uid,
      response_text
    )

    within("#ticket_#{@ticket.id}") do
      fill_in 'ticket[content]', with: response_text
      page.find(:css, 'i.bi-telegram').click
    end

    assert has_text?("#{@user.name} as @#{@organization.screen_name}")
    assert has_text?(response_text)
  end

  test 'allows replying to external tickets' do
    visit tickets_path

    response_text = 'Hello from Respondo system tests'
    external_ticket = tickets(:external)
    response = {
      external_uid: 123_456,
      external_link: external_ticket.external_link,
      author: { external_uid: '123', username: @organization.screen_name,
                external_link: 'https://external.com/matt_is_cool' },
      ticketable_attributes: {
        custom_provider: 'external'
      },
      parent_uid: external_ticket.external_uid,
      content: response_text
    }
    stub_request(:post)
      .to_return(status: 200, body: response.to_json, headers: { 'Content-Type' => 'application/json' })

    within("#ticket_#{external_ticket.id}") do
      fill_in 'ticket[content]', with: response_text
      page.find(:css, 'i.bi-telegram').click
    end

    assert has_text?("#{@user.name} as @#{@organization.screen_name}")
    assert has_text?(response_text)
  end

  test 'allows asking the AI to answer' do
    visit tickets_path

    stub_request(:post, 'https://api.openai.com/v1/chat/completions')
      .to_return(
        status: 200, body: file_fixture('openai_chat.json'),
        headers: { 'Content-Type' => 'application/json' }
      )

    within("#ticket_#{@ticket.id}") do
      page.find(:css, 'i.bi-lightning').click

      assert has_text?('You are amazing!')
    end
  end

  test 'allows asking the AI to answer with a prompt' do
    visit tickets_path

    stub_request(:post, 'https://api.openai.com/v1/chat/completions')
      .to_return(
        status: 200, body: file_fixture('openai_chat.json'),
        headers: { 'Content-Type' => 'application/json' }
      )

    within("#ticket_#{@ticket.id}") do
      fill_in 'ticket[content]', with: 'I am amazing!'
      page.find(:css, 'i.bi-lightning').click

      assert has_text?('You are amazing!')
    end
  end

  test 'allows leaving internal notes on tickets' do
    visit tickets_path

    internal_note_text = 'Internal note from Respondo system tests.'

    within("#ticket_#{@ticket.id}") do
      page.find(:css, 'i.bi-sticky').click

      fill_in 'internal_note[content]', with: internal_note_text
      click_button 'Create Note'
    end

    within("#ticket_#{@ticket.id}_internal_notes") do
      assert has_text?(@user.name)
      assert has_text?(internal_note_text)
    end
  end

  test 'allows solving tickets' do
    visit tickets_path

    within("#ticket_#{@ticket.id}") do
      select 'solved', from: 'ticket-status'
    end

    click_link 'Solved'

    assert has_text?(@ticket.author.username)
    assert has_text?(@ticket.content)
  end

  test 'allows adding ticket tags' do
    visit tickets_path

    within("#ticket_#{@ticket.id}") do
      fill_in :'acts_as_taggable_on_tag[name]', with: "hello\n"
    end

    within("#ticket_#{@ticket.id}") do
      assert has_selector?(:css, 'span', text: 'hello')
    end
  end

  test 'allows removing ticket tags' do
    @ticket.update(tag_list: 'first_tag, second_tag')
    visit tickets_path

    within("#ticket_#{@ticket.id}") do
      within('span', text: 'first_tag') do
        page.find(:css, 'i.bi-x').click
      end
    end

    within("#ticket_#{@ticket.id}") do
      assert has_no_selector?(:css, 'span', text: 'first_tag')
      assert has_selector?(:css, 'span', text: 'second_tag')
    end
  end

  test 'allows updating ticket assignment' do
    visit tickets_path

    within("#ticket_#{@ticket.id}") do
      select @user.name, from: 'ticket-assignment'
    end

    assert has_text?(@user.name)
  end

  test 'allows deleting tickets' do
    @ticket.update!(creator: @user)
    @ticket.source.update!(token: 'hello', secret: 'world')
    visit tickets_path

    stub_request(:delete, 'https://api.twitter.com/2/tweets/uid_1')
      .and_return(
        status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
        body: file_fixture('x_delete_tweet.json').read
      )

    within("#ticket_#{@ticket.id}") do
      page.find(:css, 'i.bi-three-dots').click
      click_link 'Delete'
    end

    assert has_no_text?(@ticket.content)
  end

  test 'allows navigating to tickets externally' do
    @ticket.source.update!(token: 'hello', secret: 'world')
    visit tickets_path

    within("#ticket_#{@ticket.id}") do
      page.find(:css, 'i.bi-three-dots').click

      assert_link 'External View'
    end
  end

  private

  def stub_x_reply_response(user_external_uid, user_screen_name, in_reply_to_status_id, response_text) # rubocop:disable Metrics/MethodLength
    stub_request(:get, 'https://api.twitter.com/2/tweets/1445880548472328192?expansions=author_id,referenced_tweets.id&tweet.fields=created_at').and_return(
      status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
      body: {
        data: {
          id: 123_456, text: response_text, created_at: Time.zone.now, author_id: user_external_uid,
          referenced_tweets: [{ type: 'replied_to', id: in_reply_to_status_id }]
        },
        includes: { users: [{ id: user_external_uid, username: user_screen_name }] }
      }.to_json
    )
    stub_request(:post, 'https://api.twitter.com/2/tweets')
      .with(body: { text: response_text, reply: { in_reply_to_tweet_id: in_reply_to_status_id } }.to_json)
      .and_return(
        status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
        body: file_fixture('x_create_tweet.json').read
      )
  end
end
