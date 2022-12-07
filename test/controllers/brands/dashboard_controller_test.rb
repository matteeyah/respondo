# frozen_string_literal: true

require 'test_helper'

require 'support/authentication_request_helper'

module Brands
  class DashboardControllerTest < ActionDispatch::IntegrationTest
    include AuthenticationRequestHelper

    test 'GET index when the user is authorized renders the index page' do
      sign_in(users(:john), user_accounts(:google_oauth2))
      brands(:respondo).users << users(:john)

      get "/brands/#{brands(:respondo).id}/dashboard"

      assert_select 'span.text-black', 'John Smith'
    end

    test 'GET index when the user is not authorized redirects the user to root path' do
      sign_in(users(:john), user_accounts(:google_oauth2))

      get "/brands/#{brands(:respondo).id}/dashboard"

      assert_redirected_to root_path
    end

    test 'GET index when the user is not signed in redirects the user to login path' do
      get "/brands/#{brands(:respondo).id}/dashboard"

      assert_redirected_to login_path
    end
  end
end