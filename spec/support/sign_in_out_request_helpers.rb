# frozen_string_literal: true

require './spec/support/omniauth_helpers.rb'

# This is an abstraction on top of OmniauthHelpers for request type specs.
module SignInOutRequestHelpers
  extend OmniauthHelpers

  def sign_in(user)
    account = user.user_accounts.first
    SignInOutRequestHelpers.add_oauth_mock_for_user(user, account)
    post "/auth/#{account.provider}?state=user"
    # This is a redirect to the callback controller
    follow_redirect!
    # This is a redirect back to the referrer path
    follow_redirect!
  end

  def sign_out
    delete '/sign_out'
    follow_redirect!
  end
end
