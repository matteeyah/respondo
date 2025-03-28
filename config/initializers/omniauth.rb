# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, Rails.application.credentials.google.oauth2.client_id,
           Rails.application.credentials.google.oauth2.client_secret
  provider :entra_id, {
    client_id: Rails.application.credentials.entra_id.client_id,
    client_secret: Rails.application.credentials.entra_id.client_secret
  }
  provider :twitter, Rails.application.credentials.x.api_key,
           Rails.application.credentials.x.api_secret
  provider :linkedin, client_id: Rails.application.credentials.linkedin.client_id,
                      client_secret: Rails.application.credentials.linkedin.client_secret,
                      scope: "openid profile r_basicprofile email r_organization_social rw_organization_admin " \
                             "w_member_social w_organization_social r_organization_admin"
end
