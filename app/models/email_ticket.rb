# frozen_string_literal: true

class EmailTicket < ApplicationRecord
  has_one :base_ticket, class_name: 'Ticket', as: :ticketable, touch: true, dependent: :destroy

  validates :reply_to, presence: true
  validates :reply_to, format: { with: URI::MailTo::EMAIL_REGEXP }

  validates :subject, presence: true

  def source
    base_ticket.organization
  end

  def provider
    'email'
  end

  def client
    Clients::Email.new(reply_to, subject, base_ticket.organization.id)
  end
end
