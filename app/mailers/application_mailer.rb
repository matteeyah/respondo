# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'noreply@mail.respondohub.com'
  layout 'mailer'
end
