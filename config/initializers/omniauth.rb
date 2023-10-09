# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, Rails.application.credentials.google.oauth2.client_id,
           Rails.application.credentials.google.oauth2.client_secret
  provider :azure_activedirectory_v2, {
    client_id: Rails.application.credentials.azure_active_directory.client_id,
    client_secret: Rails.application.credentials.azure_active_directory.tenant
  }
  provider :twitter, Rails.application.credentials.twitter.api_key,
           Rails.application.credentials.twitter.api_secret
  provider :disqus, Rails.application.credentials.disqus.public_key,
           Rails.application.credentials.disqus.secret_key
  provider :linkedin, client_id: Rails.application.credentials.linkedin.client_id,
                      client_secret: Rails.application.credentials.linkedin.client_secret, scope: 'openid profile email'
end

# omniauth-disqus currently has a problem with #callback_url because it passes
# the query parameters to it. This should be removed once upstream is fixed.
# https://github.com/Respondo/respondo/issues/135
OmniAuth::Strategies::Disqus.class_eval do
  def callback_url
    full_host + script_name + callback_path
  end
end
