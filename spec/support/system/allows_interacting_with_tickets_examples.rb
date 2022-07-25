# frozen_string_literal: true

RSpec.shared_examples 'allows interacting with tickets' do
  it 'allows replying to ticket' do
    user = sign_in_user
    sign_in_brand(brand)
    click_link('Brand Tickets')

    account = target_ticket.source
    account.update!(token: 'hello', secret: 'world')

    response_text = 'Hello from Respondo system tests'
    stub_twitter_reply_response(
      account.external_uid,
      brand.screen_name,
      target_ticket.external_uid,
      response_text
    )

    click_link "toggle-reply-#{target_ticket.id}"

    fill_in 'ticket[content]', with: response_text
    click_button 'Reply'

    expect(page).to have_text("#{user.name} as #{brand.screen_name}")
    expect(page).to have_text(response_text)
  end

  it 'allows replying to external tickets' do
    user = sign_in_user
    sign_in_brand(brand)
    click_link('Brand Tickets')

    response_text = 'Hello from Respondo system tests'
    target_ticket.ticketable = create(:external_ticket, response_url: 'https://example.com')
    target_ticket.author.external!
    target_ticket.save
    response = {
      external_uid: 123_456,
      author: { external_uid: '123', username: brand.screen_name },
      response_url: target_ticket.external_ticket.response_url,
      parent_uid: target_ticket.external_uid,
      content: response_text
    }
    stub_request(:post, target_ticket.external_ticket.response_url)
      .to_return(status: 200, body: response.to_json, headers: { 'Content-Type' => 'application/json' })

    click_link "toggle-reply-#{target_ticket.id}"

    fill_in 'ticket[content]', with: response_text
    click_button 'Reply'

    expect(page).to have_text("#{user.name} as #{brand.screen_name}")
    expect(page).to have_text(response_text)
  end

  it 'allows leaving internal notes on tickets' do
    user = sign_in_user
    sign_in_brand(brand)
    click_link('Brand Tickets')

    internal_note_text = 'Internal note from Respondo system tests.'

    click_link "toggle-internal-note-#{target_ticket.id}"

    fill_in 'internal_note[content]', with: internal_note_text
    click_button 'Post'

    within("#ticket_#{target_ticket.id}_internal_notes") do
      expect(page).to have_text(user.name)
      expect(page).to have_text(internal_note_text)
    end
  end

  it 'allows solving tickets' do
    sign_in_user
    sign_in_brand(brand)
    click_link('Brand Tickets')

    within("#ticket_#{target_ticket.id}") do
      select 'solved', from: 'ticket-status'
      click_button 'Update'
    end

    click_link 'Solved Tickets'

    expect(page).to have_text(target_ticket.author.username)
    expect(page).to have_text(target_ticket.content)
  end

  it 'allows adding ticket tags' do
    sign_in_user
    sign_in_brand(brand)
    click_link('Brand Tickets')

    within("#ticket_#{target_ticket.id}") do
      fill_in :'acts_as_taggable_on_tag[name]', with: 'hello'
      click_button 'Add Tags'
    end

    within("#ticket_#{target_ticket.id}") do
      expect(page).to have_selector(:css, 'span', text: 'hello')
    end
  end

  it 'allows removing ticket tags' do
    sign_in_user
    sign_in_brand(brand)
    target_ticket.update(tag_list: 'hello, world')
    click_link('Brand Tickets')

    within("#ticket_#{target_ticket.id}") do
      within('span', text: 'hello') do
        page.find(:css, 'i.bi-x').click
      end
    end

    within("#ticket_#{target_ticket.id}") do
      expect(page).not_to have_selector(:css, 'span', text: 'hello')
      expect(page).to have_selector(:css, 'span', text: 'world')
    end
  end

  it 'allows updating ticket assignment' do
    user = sign_in_user
    sign_in_brand(brand)
    click_link('Brand Tickets')

    within("#ticket_#{target_ticket.id}") do
      select user.name, from: 'ticket-assignment'
      click_button 'Assign'
    end

    within("#ticket_#{target_ticket.id}") do
      expect(page).to have_select('ticket-assignment', selected: user.name)
    end
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
