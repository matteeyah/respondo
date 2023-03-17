# frozen_string_literal: true

# Send emails at http://localhost:3000/rails/conductor/action_mailbox/inbound_emails
class InboundMailbox < ApplicationMailbox
  before_processing :organization

  def process
    Ticket.from_email({
                        from: mail.from.first, reply_to:, message_id: mail.message_id, subject: mail.subject,
                        response: mail.body.to_s, created_at: mail.date
                      }, organization, nil)
  end

  private

  def organization
    @organization ||= Organization.find(mail.to.first.match(INBOUND_REGEX).captures.first)
  rescue StandardError
    bounce_with BounceMailer.no_organization(inbound_email, reply_to)
  end

  def reply_to
    mail.reply_to || mail.from.first
  end
end
