# frozen_string_literal: true

require 'test_helper'

require 'support/authentication_request_helper'

module Mentions
  class TagsControllerTest < ActionDispatch::IntegrationTest
    include AuthenticationRequestHelper

    test 'POST create when the user is authorized redirects the user to edit page' do
      sign_in(users(:john), user_accounts(:google_oauth2))
      organizations(:respondo).users << users(:john)

      post "/mentions/#{mentions(:x).id}/tags", params: { tag: { name: 'awesome' } }

      assert_redirected_to mentions_path
    end

    test 'POST create when the user is not authorized redirects the user to root path' do
      sign_in(users(:john), user_accounts(:google_oauth2))

      post "/mentions/#{mentions(:x).id}/tags"

      assert_redirected_to root_path
    end

    test 'POST create when the user is not signed in redirects the user to login path' do
      post "/mentions/#{mentions(:x).id}/tags"

      assert_redirected_to login_path
    end

    test 'DELETE destroy when the user is authorized redirects the user to edit page' do
      sign_in(users(:john), user_accounts(:google_oauth2))
      organizations(:respondo).users << users(:john)

      mentions(:x).tags << Tag.create!(name: 'awesome')

      delete <<~TAG_PATH.chomp
        /mentions/#{mentions(:x).id}/tags/#{mentions(:x).tags.first.id}
      TAG_PATH

      assert_redirected_to mentions_path
    end

    test 'DELETE destroy when the user is not authorized redirects the user to root path' do
      sign_in(users(:john), user_accounts(:google_oauth2))

      mentions(:x).tags << Tag.create!(name: 'awesome')

      delete <<~TAG_PATH.chomp
        /mentions/#{mentions(:x).id}/tags/#{mentions(:x).tags.first.id}
      TAG_PATH

      assert_redirected_to root_path
    end

    test 'DELETE destroy when the user is not signed in redirects the user to login path' do
      mentions(:x).tags << Tag.create!(name: 'awesome')

      delete <<~TAG_PATH.chomp
        /mentions/#{mentions(:x).id}/tags/#{mentions(:x).tags.first.id}
      TAG_PATH

      assert_redirected_to login_path
    end

    test 'POST create with duplicate tag name does not create a duplicate tag' do
      sign_in(users(:john), user_accounts(:google_oauth2))
      organizations(:respondo).users << users(:john)
      mentions(:x).tags << Tag.create!(name: 'awesome')

      assert_no_changes -> { mentions(:x).reload.tags.count } do
        post "/mentions/#{mentions(:x).id}/tags", params: { tag: { name: 'awesome' } }
      end
    end
  end
end
