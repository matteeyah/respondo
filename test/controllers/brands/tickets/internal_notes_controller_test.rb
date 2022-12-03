# frozen_string_literal: true

require 'test_helper'

require 'support/authentication_request_helper'

module Brands
  module Tickets
    class InternalNotesControllerTest < ActionDispatch::IntegrationTest
      include AuthenticationRequestHelper

      test 'POST create when the user is authorized redirects the user to edit page' do
        sign_in(users(:john), user_accounts(:google_oauth2))
        brands(:respondo).users << users(:john)

        post "/brands/#{brands(:respondo).id}/tickets/#{tickets(:internal_twitter).id}/internal_notes",
             params: { internal_note: { content: 'hello' } }

        assert_redirected_to brand_ticket_path(brands(:respondo), tickets(:internal_twitter))
      end

      test 'POST create when the user is not authorized redirects the user to root path' do
        sign_in(users(:john), user_accounts(:google_oauth2))

        post "/brands/#{brands(:respondo).id}/tickets/#{tickets(:internal_twitter).id}/internal_notes"

        assert_redirected_to root_path
      end

      test 'POST create when the user is not signed in redirects the user to login path' do
        post "/brands/#{brands(:respondo).id}/tickets/#{tickets(:internal_twitter).id}/internal_notes"

        assert_redirected_to login_path
      end
    end
  end
end
