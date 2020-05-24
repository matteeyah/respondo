# frozen_string_literal: true

class InternalTicket < ApplicationRecord
  include Ticketable

  def actual_provider
    base_ticket.provider
  end
end
