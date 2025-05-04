# frozen_string_literal: true

module AuthenticationHelper
  def sign_in(user)
    visit login_path

    secret = ActiveSupport::KeyGenerator.new(
      Rails.application.secret_key_base, iterations: 1000
    ).generate_key(Rails.application.config.action_dispatch.signed_cookie_salt)

    verifier = ActiveSupport::MessageVerifier.new(secret, serializer: :json, force_legacy_metadata_serializer: true)

    page.driver.browser.manage.add_cookie(
      name: :session_id, value: verifier.generate(
        user.sessions.first.id,
        purpose: "cookie.session_id",
        expires_at: 20.years.from_now
      ),
      sameSite: :Lax, httpOnly: true
    )
  end
end
