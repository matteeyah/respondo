# frozen_string_literal: true

require 'test_helper'

require 'support/authentication_request_helper'

module User
  class PersonalAccessTokensControllerTest < ActionDispatch::IntegrationTest
    include AuthenticationRequestHelper

    test 'POST create when the user is authorized redirects the user to edit page' do
      sign_in(users(:john), user_accounts(:google_oauth2))

      post "/users/#{users(:john).id}/personal_access_tokens"

      assert_redirected_to profile_path
    end

    test 'POST create when the user is not authorized redirects the user to root path' do
      sign_in(users(:john), user_accounts(:google_oauth2))

      post "/users/#{users(:other).id}/personal_access_tokens"

      assert_redirected_to root_path
    end

    test 'POST create when the user is not signed in redirects the user to login path' do
      post "/users/#{users(:john).id}/personal_access_tokens"

      assert_redirected_to login_path
    end

    test 'DELETE destroy when the user is authorized redirects the user to edit page' do
      sign_in(users(:john), user_accounts(:google_oauth2))

      delete "/users/#{users(:john).id}/personal_access_tokens/#{personal_access_tokens(:default).id}"

      assert_redirected_to profile_path
    end

    test 'DELETE destroy when the user is not authorized redirects the user to root path' do
      sign_in(users(:john), user_accounts(:google_oauth2))

      delete "/users/#{users(:other).id}/personal_access_tokens/#{personal_access_tokens(:default).id}"

      assert_redirected_to root_path
    end

    test 'DELETE destroy when the user is not signed in redirects the user to login path' do
      delete "/users/#{users(:john).id}/personal_access_tokens/#{personal_access_tokens(:default).id}"

      assert_redirected_to login_path
    end
  end
end
