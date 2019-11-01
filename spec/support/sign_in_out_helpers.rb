# frozen_string_literal: true

require './spec/support/omniauth_helpers.rb'

module SignInOutHelpers
  include OmniauthHelpers

  def self.included(base)
    base.class_eval do
      after do
        OmniAuth.config.mock_auth.slice!(:default)
      end
    end
  end

  def sign_in(user)
    account = user.accounts.first
    add_user_oauth_mock(account.provider.to_sym, account.external_uid, user.name, account.email)
    post "/auth/#{account.provider}?model=user"
    # This is a redirect to the callback controller
    follow_redirect!
    # This is a redirect back to the referrer path
    follow_redirect!
  end

  def sign_out
    delete '/logout'
    follow_redirect!
  end
end
