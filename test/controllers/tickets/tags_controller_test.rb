# frozen_string_literal: true

require 'test_helper'

require 'support/authentication_request_helper'

module Tickets
  class TagsControllerTest < ActionDispatch::IntegrationTest
    include AuthenticationRequestHelper

    test 'POST create when the user is authorized redirects the user to edit page' do
      sign_in(users(:john), user_accounts(:google_oauth2))
      brands(:respondo).users << users(:john)

      post "/tickets/#{tickets(:twitter).id}/tags",
           params: { acts_as_taggable_on_tag: { name: 'awesome' } }

      assert_redirected_to tickets_path
    end

    test 'POST create when the user is not authorized redirects the user to root path' do
      sign_in(users(:john), user_accounts(:google_oauth2))

      post "/tickets/#{tickets(:twitter).id}/tags"

      assert_redirected_to root_path
    end

    test 'POST create when the user is not signed in redirects the user to login path' do
      post "/tickets/#{tickets(:twitter).id}/tags"

      assert_redirected_to login_path
    end

    test 'DELETE destroy when the user is authorized redirects the user to edit page' do
      sign_in(users(:john), user_accounts(:google_oauth2))
      brands(:respondo).users << users(:john)

      tickets(:twitter).tag_list.add('awesome')
      tickets(:twitter).save!

      delete <<~TAG_PATH.chomp
        /tickets/#{tickets(:twitter).id}/tags/#{tickets(:twitter).tags.first.id}
      TAG_PATH

      assert_redirected_to tickets_path
    end

    test 'DELETE destroy when the user is not authorized redirects the user to root path' do
      sign_in(users(:john), user_accounts(:google_oauth2))

      tickets(:twitter).tag_list.add('awesome')
      tickets(:twitter).save!

      delete <<~TAG_PATH.chomp
        /tickets/#{tickets(:twitter).id}/tags/#{tickets(:twitter).tags.first.id}
      TAG_PATH

      assert_redirected_to root_path
    end

    test 'DELETE destroy when the user is not signed in redirects the user to login path' do
      tickets(:twitter).tag_list.add('awesome')
      tickets(:twitter).save!

      delete <<~TAG_PATH.chomp
        /tickets/#{tickets(:twitter).id}/tags/#{tickets(:twitter).tags.first.id}
      TAG_PATH

      assert_redirected_to login_path
    end
  end
end
