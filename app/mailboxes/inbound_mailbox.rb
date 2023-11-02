# frozen_string_literal: true

# Send emails at http://localhost:3000/rails/conductor/action_mailbox/inbound_emails
class InboundMailbox < ApplicationMailbox
  before_processing :organization

  def process # rubocop:disable Metrics/AbcSize
    organization.tickets.create!(
      external_uid: mail.message_id, content: plain_body, created_at: mail.date, external_link: mail.message.link,
      ticketable_attributes: { reply_to:, subject: mail.subject },
      ticketable_type: 'EmailTicket',
      parent: organization.tickets.find_by(ticketable_type: 'EmailTicket', external_uid: mail.in_reply_to),
      author: Author.from_client!({ external_uid: mail.from.first, username: mail.from.first }, :email)
    )
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

  def plain_body # rubocop:disable Metrics/AbcSize
    if mail.multipart?
      mail.text_part.body.decoded || ActionView::Base.full_sanitizer.sanitize(mail.html_part.body.decoded).strip
    elsif mail.content_type.starts_with?('text/plain')
      mail.body.decoded
    elsif mail.content_type.starts_with?('text/html')
      ActionView::Base.full_sanitizer.sanitize(mail.body.decoded).strip
    end
  end
end
