# frozen_string_literal: true

require 'test_helper'

require 'support/authentication_request_helper'

class MentionsControllerTest < ActionDispatch::IntegrationTest
  include AuthenticationRequestHelper

  test 'GET index when the user is authorized renders the index page' do
    sign_in(users(:john), user_accounts(:google_oauth2))
    organizations(:respondo).users << users(:john)

    get '/mentions'

    assert_response :success
  end

  test 'GET index when the user is not authorized redirects the user to root path' do
    sign_in(users(:john), user_accounts(:google_oauth2))

    get '/mentions'

    assert_redirected_to root_path
  end

  test 'GET index when the user is not signed in redirects the user to login path' do
    get '/mentions'

    assert_redirected_to login_path
  end

  test 'GET show when the user is authorized renders the show page' do
    sign_in(users(:john), user_accounts(:google_oauth2))
    organizations(:respondo).users << users(:john)

    get "/mentions/#{mentions(:x).id}"

    assert_response :success
  end

  test 'GET show when the user is not authorized redirects the user to root path' do
    sign_in(users(:john), user_accounts(:google_oauth2))

    get "/mentions/#{mentions(:x).id}"

    assert_redirected_to root_path
  end

  test 'GET show when the user is not signed in redirects the user to login path' do
    get "/mentions/#{mentions(:x).id}"

    assert_redirected_to login_path
  end

  test 'PATCH update when the user is authorized redirects to external mention' do
    sign_in(users(:john), user_accounts(:google_oauth2))
    organizations(:respondo).users << users(:john)

    patch "/mentions/#{mentions(:x).id}",
          params: { mention: { content: 'hello' } }

    assert_redirected_to mentions_path(status: :open)
  end

  test 'PATCH update when the user is not authorized redirects the user to root path' do
    sign_in(users(:john), user_accounts(:google_oauth2))

    patch "/mentions/#{mentions(:x).id}"

    assert_redirected_to root_path
  end

  test 'PATCH update when the user is not signed in redirects the user to login path' do
    patch "/mentions/#{mentions(:x).id}"

    assert_redirected_to login_path
  end

  test 'DELETE destroy when the user is authorized redirects to organization mentions' do
    sign_in(users(:john), user_accounts(:google_oauth2))
    organizations(:respondo).users << users(:john)

    organization_accounts(:x).update!(token: 'hello', secret: 'world')

    stub_request(:delete, 'https://api.twitter.com/2/tweets/uid_1')
      .and_return(
        status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
        body: file_fixture('x_delete_tweet.json').read
      )

    delete "/mentions/#{mentions(:x).id}"

    assert_redirected_to mentions_path
  end

  test 'DELETE destroy when the user is not authorized redirects the user to root path' do
    sign_in(users(:john), user_accounts(:google_oauth2))

    delete "/mentions/#{mentions(:x).id}"

    assert_redirected_to root_path
  end

  test 'DELETE destroy when the user is not signed in redirects the user to login path' do
    delete "/mentions/#{mentions(:x).id}"

    assert_redirected_to login_path
  end

  test 'POST refresh when the user is authorized redirects the user to organization mentions' do
    sign_in(users(:john), user_accounts(:google_oauth2))
    organizations(:respondo).users << users(:john)

    post '/mentions/refresh'

    assert_redirected_to mentions_path
  end

  test 'POST refresh when the user is not authorized redirects the user to root path' do
    sign_in(users(:john), user_accounts(:google_oauth2))

    post '/mentions/refresh'

    assert_redirected_to root_path
  end

  test 'POST refresh when the user is not signed in redirects the user to login path' do
    post '/mentions/refresh'

    assert_redirected_to login_path
  end

  test 'GET permalink when the user is authorized redirects to external mention' do
    sign_in(users(:john), user_accounts(:google_oauth2))
    organizations(:respondo).users << users(:john)

    get "/mentions/#{mentions(:x).id}/permalink"

    assert_redirected_to 'https://x.com/twitter/status/uid_1'
  end

  test 'GET permalink when the user is not authorized redirects the user to root path' do
    sign_in(users(:john), user_accounts(:google_oauth2))

    get "/mentions/#{mentions(:x).id}/permalink"

    assert_redirected_to root_path
  end

  test 'GET permalink when the user is not signed in redirects the user to login path' do
    get "/mentions/#{mentions(:x).id}/permalink"

    assert_redirected_to login_path
  end
end
