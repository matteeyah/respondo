# frozen_string_literal: true

module TicketsHelper
  def invert_status_action(status)
    case status
    when 'open'
      bi_icon('check-lg', 'text-success fs-5')
    when 'solved'
      bi_icon('folder2-open', 'text-warning fs-5')
    end
  end

  def invert_status_action_text(status)
    case status
    when 'open'
      'Solve'
    when 'solved'
      'Open'
    end
  end

  def ticket_author_header(user_authorized, ticket)
    author_link = link_to(ticket.author.username, ticket.author.external_link)
    if user_authorized && ticket.creator
      "#{ticket.creator.name} as #{author_link}"
    else
      author_link
    end
  end
end
