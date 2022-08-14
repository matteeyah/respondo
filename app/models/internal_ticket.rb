# frozen_string_literal: true

class InternalTicket < ApplicationRecord
  has_one :base_ticket, class_name: 'Ticket', as: :ticketable, touch: true, dependent: :destroy

  belongs_to :source, class_name: 'BrandAccount'

  delegate :provider, :client, to: :source
end
