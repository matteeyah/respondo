# frozen_string_literal: true

require 'application_system_test_case'

require 'support/authentication_helper'

class BrandTest < ApplicationSystemTestCase
  include AuthenticationHelper

  def setup
    @user = users(:john)
    @brand = brands(:respondo)

    Subscription.create!(
      external_uid: 'uid_1', status: 'active', email: 'hello@respondohub.com', brand: @brand,
      cancel_url: 'https://respondohub.com/cancel', update_url: 'https://respondohub.com/update'
    )

    visit '/'

    sign_in_user(@user)
    sign_in_brand(@brand)
    click_link('Tickets')
  end

  test 'shows the tickets' do
    assert has_text?(tickets(:twitter).content)
    assert has_text?(tickets(:disqus).content)
  end

  test 'allows navigating to tickets' do
    target_ticket = tickets(:twitter)

    within("#ticket_#{target_ticket.id}") do
      page.find(:css, 'i.bi-three-dots').click
      click_link 'View'
    end

    assert has_text?(target_ticket.content)
  end

  test 'allows searching tickets by author name' do
    fill_in 'query', with: tickets(:twitter).author.username
    click_button :search

    assert has_text?(tickets(:twitter).content)
    assert has_no_text?(tickets(:disqus).content)
  end

  test 'allows searching tickets by content' do
    fill_in 'query', with: tickets(:twitter).content
    click_button :search

    assert has_text?(tickets(:twitter).content)
    assert has_no_text?(tickets(:disqus).content)
  end

  test 'keeps ticket status context when searching' do
    tickets(:disqus).update!(status: :solved)

    click_link 'Solved'

    # This is a hack to make Capybara wait until the page is loaded after navigating
    find(:xpath, "//input[@type='hidden'][@value='solved']", visible: :hidden)

    fill_in 'query', with: tickets(:disqus).author.username
    click_button :search

    assert has_no_text?(tickets(:twitter).author.username)
    assert has_text?(tickets(:disqus).author.username)
  end

  test 'allows searching by nested ticket content' do
    parent = tickets(:twitter)
    nested_ticket = Ticket.create!(
      external_uid: 'nested_1', status: :open, content: 'Lorem', parent:,
      author: authors(:james), brand: @brand, creator: @user, ticketable: internal_tickets(:twitter)
    )
    nested_nested_ticket = Ticket.create!(
      external_uid: 'nested_2', status: :open, content: 'Lorem', parent: nested_ticket,
      author: authors(:james), brand: @brand, creator: @user, ticketable: internal_tickets(:twitter)
    )

    fill_in 'query', with: nested_ticket.content
    click_button :search

    assert has_text?(nested_ticket.content)
    assert has_text?(nested_nested_ticket.content)
    assert has_no_text?(parent.content)
  end
end
