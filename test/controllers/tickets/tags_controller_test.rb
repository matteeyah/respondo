# frozen_string_literal: true

require 'test_helper'

require 'support/authentication_request_helper'

module Tickets
  class TagsControllerTest < ActionDispatch::IntegrationTest
    include AuthenticationRequestHelper

    test 'POST create when the user is authorized redirects the user to edit page' do
      sign_in(users(:john), user_accounts(:google_oauth2))
      organizations(:respondo).users << users(:john)

      post "/tickets/#{tickets(:x).id}/tags", params: { tag: { name: 'awesome' } }

      assert_redirected_to tickets_path
    end

    test 'POST create when the user is not authorized redirects the user to root path' do
      sign_in(users(:john), user_accounts(:google_oauth2))

      post "/tickets/#{tickets(:x).id}/tags"

      assert_redirected_to root_path
    end

    test 'POST create when the user is not signed in redirects the user to login path' do
      post "/tickets/#{tickets(:x).id}/tags"

      assert_redirected_to login_path
    end

    test 'DELETE destroy when the user is authorized redirects the user to edit page' do
      sign_in(users(:john), user_accounts(:google_oauth2))
      organizations(:respondo).users << users(:john)

      tickets(:x).tag_list.add('awesome')
      tickets(:x).save!

      delete <<~TAG_PATH.chomp
        /tickets/#{tickets(:x).id}/tags/#{tickets(:x).tags.first.id}
      TAG_PATH

      assert_redirected_to tickets_path
    end

    test 'DELETE destroy when the user is not authorized redirects the user to root path' do
      sign_in(users(:john), user_accounts(:google_oauth2))

      tickets(:x).tag_list.add('awesome')
      tickets(:x).save!

      delete <<~TAG_PATH.chomp
        /tickets/#{tickets(:x).id}/tags/#{tickets(:x).tags.first.id}
      TAG_PATH

      assert_redirected_to root_path
    end

    test 'DELETE destroy when the user is not signed in redirects the user to login path' do
      tickets(:x).tag_list.add('awesome')
      tickets(:x).save!

      delete <<~TAG_PATH.chomp
        /tickets/#{tickets(:x).id}/tags/#{tickets(:x).tags.first.id}
      TAG_PATH

      assert_redirected_to login_path
    end

    test 'POST create with duplicate tag name does not create a duplicate tag' do
      sign_in(users(:john), user_accounts(:google_oauth2))
      organizations(:respondo).users << users(:john)
      tickets(:x).tag_list.add('awesome')
      tickets(:x).save!

      assert_no_changes -> { tickets(:x).reload.tag_list.size } do
        post "/tickets/#{tickets(:x).id}/tags", params: { tag: { name: 'awesome' } }
      end
    end
  end
end
