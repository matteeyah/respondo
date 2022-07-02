# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV.fetch('GOOGLE_CLIENT_ID', nil), ENV.fetch('GOOGLE_CLIENT_SECRET', nil)
  provider :twitter, ENV.fetch('TWITTER_API_KEY', nil), ENV.fetch('TWITTER_API_SECRET', nil)
  provider :disqus, ENV.fetch('DISQUS_PUBLIC_KEY', nil), ENV.fetch('DISQUS_SECRET_KEY', nil)
  provider :developer, fields: %i[email name], uid_field: :email if Rails.env.development?
end

# omniauth-disqus currently has a problem with #callback_url because it passes
# the query parameters to it. This should be removed once upstream is fixed.
# https://github.com/Respondo/respondo/issues/135
OmniAuth::Strategies::Disqus.class_eval do
  def callback_url
    full_host + script_name + callback_path
  end
end
