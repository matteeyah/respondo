# frozen_string_literal: true

class InternalTicket < ApplicationRecord
  has_one :base_ticket, class_name: 'Ticket', as: :ticketable, touch: true, dependent: :destroy

  def actual_provider
    base_ticket.provider
  end
end
