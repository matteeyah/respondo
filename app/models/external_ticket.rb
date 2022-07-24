# frozen_string_literal: true

class ExternalTicket < ApplicationRecord
  has_one :base_ticket, class_name: 'Ticket', as: :ticketable, touch: true, dependent: :destroy

  validates :response_url, presence: true

  def source
    base_ticket.brand
  end

  def provider
    self[:custom_provider] || 'external'
  end
end
