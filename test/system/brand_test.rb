# frozen_string_literal: true

require 'application_system_test_case'

require 'support/authentication_helper'

class BrandTest < ApplicationSystemTestCase
  include AuthenticationHelper

  def setup
    @brand = brands(:respondo)
    @tickets = tickets(:internal_twitter, :internal_disqus)
    Subscription.create!(
      external_uid: 'uid_1', status: 'active', email: 'hello@respondo.com', brand: @brand,
      cancel_url: 'https://respondo.com/cancel', update_url: 'https://respondo.com/update'
    )

    visit '/'
  end

  test 'shows the tickets' do
    sign_in_user
    sign_in_brand(@brand)
    click_link('Tickets')

    assert has_text?(@tickets.first.content)
    assert has_text?(@tickets.second.content)
  end

  test 'allows navigating to tickets' do
    sign_in_user
    sign_in_brand(@brand)
    click_link('Tickets')

    target_ticket = @tickets.first

    within("#ticket_#{target_ticket.id}") do
      page.find(:css, 'i.bi-bullseye').click
    end

    assert has_text?(target_ticket.content)
  end

  test 'allows searching tickets by author name' do
    sign_in_user
    sign_in_brand(@brand)
    click_link('Tickets')

    fill_in 'query', with: @tickets.first.author.username
    click_button :search

    assert has_text?(@tickets.first.content)
    assert has_no_text?(@tickets.second.content)
  end

  test 'allows searching tickets by content' do
    sign_in_user
    sign_in_brand(@brand)
    click_link('Tickets')

    fill_in 'query', with: @tickets.first.content
    click_button :search

    assert has_text?(@tickets.first.content)
    assert has_no_text?(@tickets.second.content)
  end

  test 'keeps ticket status context when searching' do
    @tickets.second.update!(status: :solved)

    sign_in_user
    sign_in_brand(@brand)
    click_link('Tickets')

    click_link 'Solved'

    # This is a hack to make Capybara wait until the page is loaded after navigating
    find(:xpath, "//input[@type='hidden'][@value='solved']", visible: :hidden)

    fill_in 'query', with: @tickets.second.content
    click_button :search

    assert has_text?(@tickets.second.author.username)
    assert has_no_text?(@tickets.first.author.username)
  end

  test 'allows searching by nested ticket content' do
    nested_ticket = Ticket.create!(
      external_uid: 'nested_1', status: :open, content: 'Lorem', parent: @tickets.first,
      author: authors(:james), brand: @brand, creator: users(:john), ticketable: internal_tickets(:twitter)
    )
    nested_nested_ticket = Ticket.create!(
      external_uid: 'nested_2', status: :open, content: 'Lorem', parent: nested_ticket,
      author: authors(:james), brand: @brand, creator: users(:john), ticketable: internal_tickets(:twitter)
    )

    sign_in_user
    sign_in_brand(@brand)
    click_link('Tickets')

    fill_in 'query', with: nested_ticket.content
    click_button :search

    assert has_text?(nested_ticket.content)
    assert has_text?(nested_nested_ticket.content)
    assert has_no_text?(@tickets.first.content)
  end
end
