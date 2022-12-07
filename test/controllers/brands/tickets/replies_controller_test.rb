# frozen_string_literal: true

require 'test_helper'

require 'support/authentication_request_helper'

module Brands
  module Tickets
    class RepliesControllerTest < ActionDispatch::IntegrationTest
      include AuthenticationRequestHelper

      test 'POST create when the user is authorized redirects the user to edit page' do
        sign_in(users(:john), user_accounts(:google_oauth2))
        brands(:respondo).users << users(:john)

        Subscription.create!(
          external_uid: 'uid_1', status: 'active', email: 'hello@respondohub.com', brand: brands(:respondo),
          cancel_url: 'https://respondohub.com/cancel', update_url: 'https://respondohub.com/update'
        )
        brand_accounts(:twitter).update!(token: 'hello', secret: 'world')

        stub_request(:post, 'https://api.twitter.com/1.1/statuses/update.json')
          .to_return(
            status: 200,
            body: {
              id: 123_456,
              user: { id: 1, screen_name: 'matteeyah' },
              in_reply_to_status_id: nil,
              full_text: 'hello back'
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )

        post "/brands/#{brands(:respondo).id}/tickets/#{tickets(:twitter).id}/replies",
             params: { ticket: { content: 'hello' } }

        assert_redirected_to brand_tickets_path(brands(:respondo))
      end

      test 'POST create when the user is not authorized redirects the user to root path' do
        sign_in(users(:john), user_accounts(:google_oauth2))

        post "/brands/#{brands(:respondo).id}/tickets/#{tickets(:twitter).id}/replies"

        assert_redirected_to root_path
      end

      test 'POST create when the user is not signed in redirects the user to login path' do
        post "/brands/#{brands(:respondo).id}/tickets/#{tickets(:twitter).id}/replies"

        assert_redirected_to login_path
      end
    end
  end
end