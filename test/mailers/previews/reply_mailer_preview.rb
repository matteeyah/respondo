# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/reply_mailer
class ReplyMailerPreview < ActionMailer::Preview
  def respond
    ReplyMailer.respond('hello@example.com', nil, 'Hello World', 1, 'This is a reply')
  end
end
