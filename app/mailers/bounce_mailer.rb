# frozen_string_literal: true

class BounceMailer < ApplicationMailer
  def no_organization(_inbound_message, sender)
    mail(to: sender.username, subject: 'The organization you sent the email to does not exist.')
  end
end
