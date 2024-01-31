# frozen_string_literal: true

require "test_helper"

require "support/authentication_request_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  include AuthenticationRequestHelper

  test "DELETE destroy when user is signed in logs the user out" do
    sign_in(users(:john), user_accounts(:google_oauth2))

    delete "/sign_out"

    assert_redirected_to login_path
  end

  test "DELETE destroy when user is not signed in redirects the user to login path" do
    delete "/sign_out"

    assert_redirected_to login_path
  end
end
