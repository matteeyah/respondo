# frozen_string_literal: true

require 'test_helper'

require 'support/authentication_request_helper'

module Brands
  class UsersControllerTest < ActionDispatch::IntegrationTest
    include AuthenticationRequestHelper

    test 'POST create when the user is authorized redirects the user to edit page' do
      sign_in(users(:john), user_accounts(:google_oauth2))
      brands(:respondo).users << users(:john)

      post "/brands/#{brands(:respondo).id}/users", params: { user_id: users(:other).id }

      assert_redirected_to edit_brand_path(brands(:respondo))
    end

    test 'POST create when the user is not authorized redirects the user to root path' do
      sign_in(users(:john), user_accounts(:google_oauth2))

      post "/brands/#{brands(:respondo).id}/users"

      assert_redirected_to root_path
    end

    test 'POST create when the user is not signed in redirects the user to login path' do
      post "/brands/#{brands(:respondo).id}/users"

      assert_redirected_to login_path
    end

    test 'DELETE destroy when the user is authorized redirects the user to edit page' do
      sign_in(users(:john), user_accounts(:google_oauth2))
      brands(:respondo).users << users(:john)
      brands(:respondo).users << users(:other)

      delete "/brands/#{brands(:respondo).id}/users/#{users(:other).id}"

      assert_redirected_to edit_brand_path(brands(:respondo))
    end

    test 'DELETE destroy when the user is not authorized redirects the user to root path' do
      sign_in(users(:john), user_accounts(:google_oauth2))

      delete "/brands/#{brands(:respondo).id}/users/#{users(:john).id}"

      assert_redirected_to root_path
    end

    test 'DELETE destroy when the user is not signed in redirects the user to login path' do
      delete "/brands/#{brands(:respondo).id}/users/#{users(:john).id}"

      assert_redirected_to login_path
    end
  end
end