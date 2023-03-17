# frozen_string_literal: true

class InboundMailbox < ApplicationMailbox
  def process
    binding.break
    Ticket.create!(
      external_uid: mail.message_id, content: mail.body.to_s, created_at: mail.date,
      parent:, organization:, creator: nil, author: sender,
      ticketable: EmailTicket.new
    )
  end

  private

  def organization
    @organization ||= Organization.find(mail.to.first.match(INBOUND_REGEX).captures.first)
  rescue StandardError
    bounce_with # TODO
  end

  def parent
    @parent ||= organization.tickets.find_by(external_uid: mail.headers['In-Reply-To'])
  end

  def sender
    @sender ||= Author.find_or_create_by(username: mail.from.first)
  end
end
