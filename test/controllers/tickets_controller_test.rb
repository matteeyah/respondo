# frozen_string_literal: true

require 'test_helper'

require 'support/authentication_request_helper'

class TicketsControllerTest < ActionDispatch::IntegrationTest
  include AuthenticationRequestHelper

  test 'GET index when the user is authorized renders the index page' do
    sign_in(users(:john), user_accounts(:google_oauth2))
    organizations(:respondo).users << users(:john)

    get '/tickets'

    assert_response :success
  end

  test 'GET index when the user is not authorized redirects the user to root path' do
    sign_in(users(:john), user_accounts(:google_oauth2))

    get '/tickets'

    assert_redirected_to root_path
  end

  test 'GET index when the user is not signed in redirects the user to login path' do
    get '/tickets'

    assert_redirected_to login_path
  end

  test 'GET show when the user is authorized renders the show page' do
    sign_in(users(:john), user_accounts(:google_oauth2))
    organizations(:respondo).users << users(:john)

    get "/tickets/#{tickets(:twitter).id}"

    assert_response :success
  end

  test 'GET show when the user is not authorized redirects the user to root path' do
    sign_in(users(:john), user_accounts(:google_oauth2))

    get "/tickets/#{tickets(:twitter).id}"

    assert_redirected_to root_path
  end

  test 'GET show when the user is not signed in redirects the user to login path' do
    get "/tickets/#{tickets(:twitter).id}"

    assert_redirected_to login_path
  end

  test 'PATCH update when the user is authorized redirects to external ticket' do
    sign_in(users(:john), user_accounts(:google_oauth2))
    organizations(:respondo).users << users(:john)

    patch "/tickets/#{tickets(:twitter).id}",
          params: { ticket: { content: 'hello' } }

    assert_redirected_to tickets_path(status: :open)
  end

  test 'PATCH update when the user is not authorized redirects the user to root path' do
    sign_in(users(:john), user_accounts(:google_oauth2))

    patch "/tickets/#{tickets(:twitter).id}"

    assert_redirected_to root_path
  end

  test 'PATCH update when the user is not signed in redirects the user to login path' do
    patch "/tickets/#{tickets(:twitter).id}"

    assert_redirected_to login_path
  end

  test 'DELETE destroy when the user is authorized redirects to organization tickets' do
    sign_in(users(:john), user_accounts(:google_oauth2))
    organizations(:respondo).users << users(:john)

    organization_accounts(:twitter).update!(token: 'hello', secret: 'world')

    stub_request(:delete, 'https://api.twitter.com/2/tweets/uid_1')
      .and_return(
        status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
        body: file_fixture('twitter_delete_tweet.json').read
      )

    delete "/tickets/#{tickets(:twitter).id}"

    assert_redirected_to tickets_path
  end

  test 'DELETE destroy when the user is not authorized redirects the user to root path' do
    sign_in(users(:john), user_accounts(:google_oauth2))

    delete "/tickets/#{tickets(:twitter).id}"

    assert_redirected_to root_path
  end

  test 'DELETE destroy when the user is not signed in redirects the user to login path' do
    delete "/tickets/#{tickets(:twitter).id}"

    assert_redirected_to login_path
  end

  test 'POST refresh when the user is authorized redirects the user to organization tickets' do
    sign_in(users(:john), user_accounts(:google_oauth2))
    organizations(:respondo).users << users(:john)

    post '/tickets/refresh'

    assert_redirected_to tickets_path
  end

  test 'POST refresh when the user is not authorized redirects the user to root path' do
    sign_in(users(:john), user_accounts(:google_oauth2))

    post '/tickets/refresh'

    assert_redirected_to root_path
  end

  test 'POST refresh when the user is not signed in redirects the user to login path' do
    post '/tickets/refresh'

    assert_redirected_to login_path
  end

  test 'GET permalink when the user is authorized redirects to external ticket' do
    sign_in(users(:john), user_accounts(:google_oauth2))
    organizations(:respondo).users << users(:john)

    get "/tickets/#{tickets(:twitter).id}/permalink"

    assert_redirected_to 'https://x.com/twitter/status/uid_1'
  end

  test 'GET permalink when the user is not authorized redirects the user to root path' do
    sign_in(users(:john), user_accounts(:google_oauth2))

    get "/tickets/#{tickets(:twitter).id}/permalink"

    assert_redirected_to root_path
  end

  test 'GET permalink when the user is not signed in redirects the user to login path' do
    get "/tickets/#{tickets(:twitter).id}/permalink"

    assert_redirected_to login_path
  end
end
