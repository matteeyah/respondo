# frozen_string_literal: true

require "test_helper"

require "support/authentication_request_helper"

module Mentions
  class SyncControllerTest < ActionDispatch::IntegrationTest
    include AuthenticationRequestHelper

    test "POST create when the user is authorized redirects the user to organization mentions" do
      sign_in(users(:john), user_accounts(:google_oauth2))
      organizations(:respondo).users << users(:john)

      post "/mentions/sync"

      assert_redirected_to mentions_path
    end

    test "POST create when the user is not authorized redirects the user to root path" do
      sign_in(users(:john), user_accounts(:google_oauth2))

      post "/mentions/sync"

      assert_redirected_to root_path
    end

    test "POST create when the user is not signed in redirects the user to login path" do
      post "/mentions/sync"

      assert_redirected_to login_path
    end
  end
end
