# frozen_string_literal: true

class ReplyMailer < ApplicationMailer
  def respond(address, in_reply_to, subject, organization_id, message)
    @message = message

    headers['In-Reply-To'] = in_reply_to
    headers['References'] = in_reply_to
    mail(to: address, reply_to: reply_to(organization_id), subject: "RE: #{subject}")
  end

  private

  def reply_to(organization_id)
    "inbound+#{organization_id}@mail.respondohub.com"
  end
end
