# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, Rails.application.credentials.google.client_id, Rails.application.credentials.google.client_secret
  provider :activedirectory, Rails.application.credentials.azure_active_directory.client_id, Rails.application.credentials.azure_active_directory.tenant
  provider :twitter, Rails.application.credentials.twitter.api_key, Rails.application.credentials.twitter.api_secret
  provider :disqus, Rails.application.credentials.disqus.public_key, Rails.application.credentials.disqus.secret_key
  provider :developer, fields: %i[email name nickname], uid_field: :email if Rails.env.development?
end

# omniauth-disqus currently has a problem with #callback_url because it passes
# the query parameters to it. This should be removed once upstream is fixed.
# https://github.com/Respondo/respondo/issues/135
OmniAuth::Strategies::Disqus.class_eval do
  def callback_url
    full_host + script_name + callback_path
  end
end
