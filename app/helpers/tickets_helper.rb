# frozen_string_literal: true

module TicketsHelper
  def invert_status_action(status)
    case status
    when 'open'
      bi_icon('check', 'fs-5')
    when 'solved'
      bi_icon('folder2-open', 'fs-5')
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

  def ticket_header_content(user_authorized, ticket)
    <<~TICKET_HEADER.delete("\n")
      #{ticket_author_header(user_authorized, ticket)} - 
      #{link_to(ticket.created_at.to_formatted_s(:short), brand_ticket_path(ticket.brand, ticket), 'data-turbo' => false)}
    TICKET_HEADER
  end

  private

  def ticket_author_header(user_authorized, ticket)
    author_link = link_to(ticket.author.username, ticket.author.external_link)
    if user_authorized && ticket.creator
      "#{ticket.creator.name} as #{author_link}"
    elsif ticket.parent_id.nil?
      "#{author_link} - #{ticket.actual_provider}"
    else
      author_link
    end
  end
end
