# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET']
  provider :twitter, ENV['TWITTER_API_KEY'], ENV['TWITTER_API_SECRET']
  provider :disqus, ENV['DISQUS_PUBLIC_KEY'], ENV['DISQUS_SECRET_KEY']
end

# omniauth-disqus currently has a problem with #callback_url because it passes
# the query parameters to it. This should be removed once upstream is fixed.
# https://github.com/Respondo/respondo/issues/135
OmniAuth::Strategies::Disqus.class_eval do
  def callback_url
    full_host + script_name + callback_path
  end
end
