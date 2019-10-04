# frozen_string_literal: true

module SignInOutHelpers
  def self.included(base)
    base.class_eval do
      after do
        OmniAuth.config.mock_auth.delete(:twitter)
        OmniAuth.config.mock_auth.delete(:google_oauth2)
      end
    end
  end

  def sign_in(user)
    OmniAuth.config.add_mock(:google_oauth2,
                             uid: user.google_oauth2_account.external_uid,
                             info: { name: user.name, email: user.google_oauth2_account.email },
                             credentials: {})
    get '/auth/google_oauth2?model=user'
    follow_redirect!
    follow_redirect!
  end
end
