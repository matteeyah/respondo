# frozen_string_literal: true

require 'test_helper'

require 'support/authentication_request_helper'

class OrganizationsControllerTest < ActionDispatch::IntegrationTest
  include AuthenticationRequestHelper

  test 'GET edit when the user is authorized renders the edit page' do
    sign_in(users(:john), user_accounts(:google_oauth2))
    organizations(:respondo).users << users(:john)

    get '/settings'

    assert_select 'span', organizations(:respondo).screen_name
  end

  test 'GET edit when the user is not authorized redirects the user to root path' do
    sign_in(users(:john), user_accounts(:google_oauth2))

    get '/settings'

    assert_redirected_to root_path
  end

  test 'GET edit when the user is not signed in redirects the user to login path' do
    get '/settings'

    assert_redirected_to login_path
  end

  test 'PATCH update when the user is authorized when params are valid updates the organization' do
    sign_in(users(:john), user_accounts(:google_oauth2))
    organizations(:respondo).users << users(:john)

    assert_changes -> { organizations(:respondo).reload.domain }, from: nil, to: 'domain.com' do
      patch '/organization', params: { organization: { domain: 'domain.com' } }
    end
  end

  test 'PATCH update when the user is authorized redirects to edit organization path' do
    sign_in(users(:john), user_accounts(:google_oauth2))
    organizations(:respondo).users << users(:john)

    patch '/organization', params: { organization: { domain: 'domain.com' } }

    assert_redirected_to settings_path
  end

  test 'PATCH update when the user is authorized when params are not valid does not update the organization' do
    sign_in(users(:john), user_accounts(:google_oauth2))
    organizations(:respondo).users << users(:john)

    assert_no_changes -> { organizations(:respondo).domain }, from: nil do
      patch '/organization', params: { organization: { domain: 'invalid!domain.com' } }
    end
  end

  test 'PATCH update when the user is not authorzied redirects the user to root path' do
    sign_in(users(:john), user_accounts(:google_oauth2))

    patch '/organization'

    assert_redirected_to root_path
  end

  test 'PATCH update when the user is not signed in redirects the user to login path' do
    patch '/organization'

    assert_redirected_to login_path
  end
end
