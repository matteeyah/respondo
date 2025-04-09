# frozen_string_literal: true

require "test_helper"

require "support/authentication_request_helper"

class OnboardingsControllerTest < ActionDispatch::IntegrationTest
  include AuthenticationRequestHelper
  test "GET new when the user is signed in renders the home page" do
    sign_in(users(:john), user_accounts(:google_oauth2))

    get "/onboardings/new"

    assert_select "h2", "Woohoo, you're in!"
  end

  test "GET new when the user is not signed in redirects to the login path" do
    get "/onboardings/new"

    assert_redirected_to login_path
  end
end
