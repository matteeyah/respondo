# frozen_string_literal: true

require 'support/omniauth_helper'

# This is an abstraction on top of OmniauthHelpers for controller type specs.
module AuthenticationRequestHelper
  extend OmniauthHelper

  def sign_in(user, account)
    AuthenticationRequestHelper.add_oauth_mock_for_user(user, account)
    post "/auth/#{account.provider}"
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
