# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, Rails.application.credentials.google.oauth2.client_id,
           Rails.application.credentials.google.oauth2.client_secret
  provider :azure_activedirectory_v2, {
    client_id: Rails.application.credentials.azure_active_directory.client_id,
    client_secret: Rails.application.credentials.azure_active_directory.client_secret
  }
  provider :twitter, Rails.application.credentials.twitter.api_key,
           Rails.application.credentials.twitter.api_secret
  provider :linkedin, client_id: Rails.application.credentials.linkedin.client_id,
                      client_secret: Rails.application.credentials.linkedin.client_secret, scope: 'openid profile email'
end
