# frozen_string_literal: true

require 'support/omniauth_helper'

# This is an abstraction on top of OmniauthHelpers for system type specs.
module AuthenticationHelper
  extend OmniauthHelper

  def sign_in_user(user = nil)
    (user || FactoryBot.create(:user, :with_account)).tap do |active_user|
      AuthenticationHelper.add_oauth_mock_for_user(active_user)
      click_button('Sign in with Google')
    end
  end

  def sign_in_brand(brand = nil)
    (brand || FactoryBot.create(:brand, :with_account)).tap do |active_brand|
      AuthenticationHelper.add_oauth_mock_for_brand(active_brand)
      click_button('Authorize')
    end
  end
end
