# frozen_string_literal: true

require './spec/support/omniauth_helpers'

# This is an abstraction on top of OmniauthHelpers for system type specs.
module SignInOutSystemHelpers
  extend OmniauthHelpers

  def sign_in_user(user = nil)
    (user || FactoryBot.create(:user, :with_account)).tap do |active_user|
      SignInOutSystemHelpers.add_oauth_mock_for_user(active_user)
      click_button('Sign In', class: 'nav-link')
    end
  end

  def sign_in_brand(brand = nil)
    (brand || FactoryBot.create(:brand, :with_account)).tap do |active_brand|
      SignInOutSystemHelpers.add_oauth_mock_for_brand(active_brand)
      click_button('Authorize Brand', class: 'nav-link')
    end
  end
end
