# frozen_string_literal: true

require 'support/omniauth_helper'

# This is an abstraction on top of OmniauthHelpers for system type specs.
module AuthenticationHelper
  extend OmniauthHelper

  def sign_in_user(user = users(:john))
    user.tap do |active_user|
      AuthenticationHelper.add_oauth_mock_for_user(active_user, user_accounts(:google_oauth2))
      click_button('Sign in with Google')
    end
  end

  def sign_in_brand(brand = brands(:respondo))
    brand.tap do |active_brand|
      AuthenticationHelper.add_oauth_mock_for_brand(active_brand, brand_accounts(:twitter))
      click_button('Authorize')
    end
  end
end
