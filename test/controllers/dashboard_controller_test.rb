# frozen_string_literal: true

require "test_helper"

require "support/authentication_request_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  include AuthenticationRequestHelper

  test "GET show when the user is authorized renders the index page" do
    sign_in(users(:john), user_accounts(:google_oauth2))
    organizations(:respondo).users << users(:john)

    get "/dashboard"

    assert_select "h3", "Overview"
  end

  test "GET show when the user is not authorized redirects the user to root path" do
    sign_in(users(:john), user_accounts(:google_oauth2))

    get "/dashboard"

    assert_redirected_to root_path
  end

  test "GET show when the user is not signed in redirects the user to login path" do
    get "/dashboard"

    assert_redirected_to login_path
  end
end
