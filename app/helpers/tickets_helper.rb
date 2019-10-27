# typed: true
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
end
