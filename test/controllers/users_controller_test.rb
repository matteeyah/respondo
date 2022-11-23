# frozen_string_literal: true

require 'test_helper'

require 'support/authentication_request_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  include AuthenticationRequestHelper

  test 'GET edit when the user is authorized renders the edit page' do
    sign_in(users(:john), user_accounts(:google_oauth2))

    get "/users/#{users(:john).id}/edit"

    assert_select 'span', users(:john).name
  end

  test 'GET edit when the user is not authorized redirects the user to root path' do
    sign_in(users(:john), user_accounts(:google_oauth2))

    get "/users/#{users(:other).id}/edit"

    assert_redirected_to root_path
  end

  test 'GET edit when the user is not signed in redirects the user to login path' do
    get "/users/#{users(:john).id}/edit"

    assert_redirected_to login_path
  end
end
