# frozen_string_literal: true

module AuthenticationHelper
  def sign_in(user)
    visit login_path

    session = { session_id: SecureRandom.hex(32), user_id: user.id }
    page.driver.browser.manage.add_cookie(
      name: Rails.application.config.session_options[:key], value: encrypt_and_sign_cookie(session),
      sameSite: :Lax, httpOnly: true
    )
  end

  private

  def encrypt_and_sign_cookie(cookie) # rubocop:disable Metrics/AbcSize
    salt = Rails.application.config.action_dispatch.authenticated_encrypted_cookie_salt
    encrypted_cookie_cipher = Rails.application.config.action_dispatch.encrypted_cookie_cipher || "aes-256-gcm"

    key_generator = ActiveSupport::KeyGenerator.new(Rails.application.secret_key_base, iterations: 1000)
    secret = key_generator.generate_key(salt, ActiveSupport::MessageEncryptor.key_len(encrypted_cookie_cipher))
    encryptor = ActiveSupport::MessageEncryptor.new(
      secret, cipher: encrypted_cookie_cipher, serializer: :json, force_legacy_metadata_serializer: true
    )

    session_key = Rails.application.config.session_options[:key].freeze
    signed_cookie = encryptor.encrypt_and_sign(cookie, purpose: "cookie.#{session_key}")
    CGI.escape(signed_cookie)
  end
end
