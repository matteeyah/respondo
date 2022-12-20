# frozen_string_literal: true

require 'test_helper'

require 'support/authentication_request_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  include AuthenticationRequestHelper

  test 'GET edit when the user is authorized renders the edit page' do
    sign_in(users(:john), user_accounts(:google_oauth2))

    get '/profile'

    assert_select 'span', users(:john).name
  end

  test 'GET edit when the user is not signed in redirects the user to login path' do
    get '/profile'

    assert_redirected_to login_path
  end
end
