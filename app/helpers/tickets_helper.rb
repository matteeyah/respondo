# frozen_string_literal: true

module TicketsHelper
  def ticket_author_header(ticket)
    author_link = link_to(ticket.author.username, ticket.author.external_link, class: 'text-decoration-none')
    if ticket.creator
      "#{ticket.creator.name} as #{author_link}"
    else
      author_link
    end
  end
end
