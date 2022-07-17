# frozen_string_literal: true

module TicketsHelper
  def ticket_author_header(user_authorized, ticket)
    author_link = link_to(ticket.author.username, ticket.author.external_link, class: 'text-decoration-none')
    if user_authorized && ticket.creator
      "#{ticket.creator.name} as #{author_link}"
    else
      author_link
    end
  end

  def ticket_provider_as_author_link(user_authorized, ticket)
    author_link = link_to(ticket.author.username, ticket.author.external_link)
    if user_authorized && ticket.creator
      "#{ticket.actual_provider} as #{author_link}"
    else
      author_link
    end
  end
end
