# frozen_string_literal: true

require "test_helper"

require "support/authentication_request_helper"

module Mentions
  class PermalinksControllerTest < ActionDispatch::IntegrationTest
    include AuthenticationRequestHelper

    test "GET show when the user is authorized redirects to external mention" do
      sign_in(users(:john), user_accounts(:google_oauth2))
      organizations(:respondo).users << users(:john)

      get "/mentions/#{mentions(:x).id}/permalink"

      assert_redirected_to "https://x.com/twitter/status/uid_1"
    end

    test "GET show when the user is not authorized redirects the user to root path" do
      sign_in(users(:john), user_accounts(:google_oauth2))

      get "/mentions/#{mentions(:x).id}/permalink"

      assert_redirected_to root_path
    end

    test "GET show when the user is not signed in redirects the user to login path" do
      get "/mentions/#{mentions(:x).id}/permalink"

      assert_redirected_to login_path
    end
  end
end
