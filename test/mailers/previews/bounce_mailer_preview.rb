# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/bounce_mailer
class BounceMailerPreview < ActionMailer::Preview
  def no_organization
    BounceMailer.no_organization(Mail.new, Author.new(username: 'hello@example.com'))
  end
end
