# frozen_string_literal: true

require "test_helper"

require "support/authentication_request_helper"

module Organizations
  class UsersControllerTest < ActionDispatch::IntegrationTest
    include AuthenticationRequestHelper

    test "POST create when the user is authorized redirects the user to edit page" do
      sign_in(users(:john), user_accounts(:google_oauth2))
      organizations(:respondo).users << users(:john)

      post "/organization/users", params: { user_id: users(:other).id }

      assert_redirected_to settings_path
    end

    test "POST create when the user is not authorized redirects the user to root path" do
      sign_in(users(:john), user_accounts(:google_oauth2))

      post "/organization/users"

      assert_redirected_to root_path
    end

    test "POST create when the user is not signed in redirects the user to login path" do
      post "/organization/users"

      assert_redirected_to login_path
    end

    test "DELETE destroy when the user is authorized redirects the user to edit page" do
      sign_in(users(:john), user_accounts(:google_oauth2))
      organizations(:respondo).users << users(:john)
      organizations(:respondo).users << users(:other)

      delete "/organization/users/#{users(:other).id}"

      assert_redirected_to settings_path
    end

    test "DELETE destroy when the user is not authorized redirects the user to root path" do
      sign_in(users(:john), user_accounts(:google_oauth2))

      delete "/organization/users/#{users(:john).id}"

      assert_redirected_to root_path
    end

    test "DELETE destroy when the user is not signed in redirects the user to login path" do
      delete "/organization/users/#{users(:john).id}"

      assert_redirected_to login_path
    end
  end
end
