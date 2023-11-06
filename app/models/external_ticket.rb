# frozen_string_literal: true

class ExternalTicket < ApplicationRecord
  has_one :base_ticket, class_name: 'Ticket', as: :ticketable, touch: true, dependent: :destroy

  def source
    base_ticket.organization
  end

  def provider
    self[:custom_provider] || 'external'
  end

  def client
    Clients::External.new(base_ticket.external_link)
  end
end
