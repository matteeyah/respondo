# frozen_string_literal: true

module TicketsHelper
  def invert_status_action(status)
    case status
    when 'open'
      bi_icon('check-circle-fill', 'text-primary fs-4')
    when 'solved'
      bi_icon('backspace-fill', 'text-primary fs-4')
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
