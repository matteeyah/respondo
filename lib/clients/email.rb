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
        external_uid: mail.message_id, content: response_text, created_at: mail.date,
        author: { external_uid: mail.from.first, username: mail.from.first },
        ticketable_attributes: { reply_to: mail.reply_to.first, subject: mail.subject },
        parent_uid: mail.in_reply_to
      }
    end

    def delete(_external_uid)
      true
    end

    def permalink(_link)
      'https://app.respondohub.com/tickets'
    end
  end
end
