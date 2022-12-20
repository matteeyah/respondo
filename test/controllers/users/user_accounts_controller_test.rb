# frozen_string_literal: true

require 'test_helper'

require 'support/authentication_request_helper'

module Users
  class UserAccountsControllerTest < ActionDispatch::IntegrationTest
    include AuthenticationRequestHelper

    test 'DELETE destroy when the user is authorized redirects to edit page' do
      sign_in(users(:john), user_accounts(:google_oauth2))

      delete "/users/#{users(:john).id}/user_accounts/#{user_accounts(:google_oauth2).id}"

      assert_redirected_to profile_path
    end

    test 'DELETE destroy when the user is not authorized redirects the user to root path' do
      sign_in(users(:john), user_accounts(:google_oauth2))

      delete "/users/#{users(:other).id}/user_accounts/#{user_accounts(:google_oauth2).id}"

      assert_redirected_to root_path
    end

    test 'DELETE destroy when the user is not signed in redirects the user to login path' do
      delete "/users/#{users(:john).id}/user_accounts/#{user_accounts(:google_oauth2).id}"

      assert_redirected_to login_path
    end
  end
end
