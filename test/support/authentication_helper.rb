# frozen_string_literal: true

require 'support/omniauth_helper'

# This is an abstraction on top of OmniauthHelpers for system type specs.
module AuthenticationHelper
  extend OmniauthHelper

  def sign_in_user(user)
    AuthenticationHelper.add_oauth_mock_for_user(user, user_accounts(:google_oauth2))
    click_button('Sign in with Google')
  end

  def sign_in_brand(brand)
    AuthenticationHelper.add_oauth_mock_for_brand(brand, brand_accounts(:twitter))
    click_button('Authorize')
  end
end
