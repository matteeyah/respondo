# frozen_string_literal: true

require 'test_helper'

require 'support/authentication_request_helper'

module Tickets
  class AssignmentsControllerTest < ActionDispatch::IntegrationTest
    include AuthenticationRequestHelper

    test 'POST create when the user is authorized redirects the user to edit page' do
      sign_in(users(:john), user_accounts(:google_oauth2))
      brands(:respondo).users << users(:john)

      post "/tickets/#{tickets(:twitter).id}/assignments",
        params: { ticket: { assignment: { user_id: users(:john).id } } }

        assert_redirected_to brand_tickets_path(brands(:respondo))
    end

    test 'POST create when the user is not authorized redirects the user to root path' do
      sign_in(users(:john), user_accounts(:google_oauth2))

      post "/tickets/#{tickets(:twitter).id}/assignments"

      assert_redirected_to root_path
    end

    test 'POST create when the user is not signed in redirects the user to login path' do
      post "/tickets/#{tickets(:twitter).id}/assignments"

      assert_redirected_to login_path
    end
  end
end
