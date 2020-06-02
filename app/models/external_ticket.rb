# frozen_string_literal: true

class ExternalTicket < ApplicationRecord
  include Ticketable

  validates :response_url, presence: true

  def actual_provider
    self[:custom_provider] || base_ticket.provider
  end
end
