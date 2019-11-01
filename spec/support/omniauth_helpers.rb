# frozen_string_literal: true

module OmniauthHelpers
  def add_user_oauth_mock(provider, external_uid, name, email)
    OmniAuth.config.add_mock(provider,
                             uid: external_uid,
                             info: { name: name, email: email },
                             credentials: {})
  end

  def add_brand_oauth_mock(provider, external_uid, screen_name, token, secret)
    OmniAuth.config.add_mock(provider,
                             uid: external_uid,
                             info: { nickname: screen_name },
                             credentials: { token: token, secret: secret })
  end
end
