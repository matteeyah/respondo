# frozen_string_literal: true

require 'test_helper'

class TicketsHelperTest < ActionView::TestCase
  test '#ticket_author_header shows provider when ticket is root' do
    parent_ticket = create(:internal_ticket).base_ticket
    ticket = create(:internal_ticket, parent: parent_ticket, brand: parent_ticket.brand).base_ticket
    author_link = link_to(ticket.author.username, ticket.author.external_link, class: 'text-decoration-none')

    assert_equal author_link, ticket_author_header(false, ticket)
  end

  test '#ticket_author_header shows local author when ticket is from respondo' do
    ticket = create(:internal_ticket, creator: create(:user)).base_ticket
    author_link = link_to(ticket.author.username, ticket.author.external_link, class: 'text-decoration-none')

    assert_equal "#{ticket.creator.name} as #{author_link}", ticket_author_header(true, ticket)
  end
end
