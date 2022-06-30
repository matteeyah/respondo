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
    header_content = ticket.author.username

    if user_authorized && ticket.creator
      header_content = "#{ticket.creator.name} as #{header_content}"
    elsif ticket.parent_id.nil?
      header_content = "#{header_content} - #{ticket.actual_provider}"
    end

    ticket_link = link_to(ticket.created_at.to_formatted_s(:short), brand_ticket_path(ticket.brand, ticket),
                          'data-turbo' => false)
    "#{sanitize(header_content)} - #{ticket_link}"
  end

  def flatten_hash(hash)
    hash.flat_map { |k, v| [k, *flatten_hash(v)] }
  end
end
