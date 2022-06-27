# frozen_string_literal: true

module UsersHelper
  def user_gravatar(user)
    gravatar_id = Digest::MD5.hexdigest(user.accounts.first.email.to_s.downcase)
    gravatar_url = "http://secure.gravatar.com/avatar/#{gravatar_id}"
    image_tag(gravatar_url, alt: user.name, height: '32px', width: '32px')
  end
end
