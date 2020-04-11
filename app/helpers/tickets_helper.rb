# frozen_string_literal: true

module TicketsHelper
  def invert_status_action(status)
    case status
    when 'open'
      'Solve'
    when 'solved'
      'Open'
    end
  end

  def ticket_header_content(user_authorized, ticket, brand)
    header_content = ticket.author.username

    if user_authorized && ticket.user
      header_content = "#{ticket.user.name} as #{header_content}"
    elsif ticket.parent_id.nil?
      header_content = "#{header_content} - #{ticket.actual_provider}"
    end

    sanitize("#{header_content} - #{link_to(ticket.created_at.to_formatted_s(:short), brand_ticket_path(brand, ticket))}")
  end
end
