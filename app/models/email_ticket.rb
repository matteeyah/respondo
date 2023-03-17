# frozen_string_literal: true

class EmailTicket < ApplicationRecord
  has_one :base_ticket, class_name: 'Ticket', as: :ticketable, touch: true, dependent: :destroy

  def source
    base_ticket.organization
  end

  def client
    Clients::External.new(response_url)
  end
end
