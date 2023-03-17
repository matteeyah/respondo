# frozen_string_literal: true

module Clients
  class Email < Clients::ProviderClient
    def initialize(reply_to, subject, organization_id)
      super()

      @reply_to = reply_to
      @subject = subject
      @organization_id = organization_id
    end

    def reply(response_text, external_uid)
      mail = ReplyMailer.respond(@reply_to, external_uid, @subject, @organization_id, response_text).deliver_now
      {
        from: mail.from.first, reply_to: mail.reply_to.first, message_id: mail.message_id,
        subject: mail.subject, response: mail.body.to_s, created_at: mail.date,
        in_reply_to: mail.in_reply_to
      }
    end

    def delete(_external_uid)
      true
    end

    def permalink(_external_uid)
      'https://app.respondohub.com/tickets'
    end
  end
end
