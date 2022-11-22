# frozen_string_literal: true

require 'test_helper'

class TicketsHelperTest < ActionView::TestCase
  test '#ticket_author_header shows provider when ticket is root' do
    parent_ticket = tickets(:internal_twitter)
    ticket = Ticket.create!(
      external_uid: 'hello_world', status: :open, content: 'Lorem ipsum dolor sit amet',
      parent: parent_ticket, author: authors(:james), brand: brands(:respondo), ticketable: internal_tickets(:twitter)
    )
    author_link = link_to(ticket.author.username, ticket.author.external_link, class: 'text-decoration-none')

    assert_equal author_link, ticket_author_header(ticket)
  end

  test '#ticket_author_header shows local author when ticket is from respondo' do
    ticket = tickets(:internal_twitter)
    ticket.update!(creator: users(:john))
    author_link = link_to(ticket.author.username, ticket.author.external_link, class: 'text-decoration-none')

    assert_equal "#{ticket.creator.name} as #{author_link}", ticket_author_header(ticket)
  end
end
