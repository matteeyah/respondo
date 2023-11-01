# frozen_string_literal: true

LI_SCOPES = 'openid profile r_ads_reporting r_organization_social rw_organization_admin w_member_social r_ads ' \
            'w_organization_social rw_ads r_basicprofile r_organization_admin email r_1st_connections_size'

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, Rails.application.credentials.google.oauth2.client_id,
           Rails.application.credentials.google.oauth2.client_secret
  provider :azure_activedirectory_v2, {
    client_id: Rails.application.credentials.azure_active_directory.client_id,
    client_secret: Rails.application.credentials.azure_active_directory.client_secret
  }
  provider :twitter, Rails.application.credentials.x.api_key,
           Rails.application.credentials.x.api_secret
  provider :linkedin, client_id: Rails.application.credentials.linkedin.client_id,
                      client_secret: Rails.application.credentials.linkedin.client_secret, scope: LI_SCOPES
end
