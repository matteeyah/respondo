# frozen_string_literal: true

# Send emails at http://localhost:3000/rails/conductor/action_mailbox/inbound_emails
class InboundMailbox < ApplicationMailbox
  before_processing :organization

  def process
    Ticket.from_email({
                        from: mail.from.first, reply_to:, message_id: mail.message_id, subject: mail.subject,
                        response: plain_body, created_at: mail.date
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

  def plain_body # rubocop:disable Metrics/AbcSize
    if mail.multipart?
      mail.text_part || ActionView::Base.full_sanitizer.sanitize(mail.html_part).strip
    elsif mail.content_type.starts_with?('text/plain')
      mail.body.to_s
    elsif mail.content_type.starts_with?('text/html')
      ActionView::Base.full_sanitizer.sanitize(mail.body.to_s).strip
    end
  end
end
