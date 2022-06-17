# frozen_string_literal: true

module TicketsHelper
  def invert_status_action(status)
    case status
    when 'open'
      fa_icon('check')
    when 'solved'
      fa_icon('folder-open')
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

  def ticket_header_content(user_authorized, ticket, brand)
    header_content = ticket.author.username

    if user_authorized && ticket.creator
      header_content = "#{ticket.creator.name} as #{header_content}"
    elsif ticket.parent_id.nil?
      header_content = "#{header_content} - #{ticket.actual_provider}"
    end

    ticket_link = link_to(ticket.created_at.to_formatted_s(:short), brand_ticket_path(brand, ticket),
                          'data-turbo' => false)
    "#{sanitize(header_content)} - #{ticket_link}"
  end

  def flatten_hash(hash)
    hash.flat_map { |k, v| [k, *flatten_hash(v)] }
  end
end
