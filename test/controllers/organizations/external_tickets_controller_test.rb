# frozen_string_literal: true

require 'test_helper'

module Organizations
  class ExternalTicketsControllerTest < ActionDispatch::IntegrationTest
    test 'POST create.json when token is authorized when payload is valid' do
      organizations(:respondo).users << users(:john)

      assert_changes -> { Ticket.count }, from: 3, to: 4 do
        post "/organizations/#{organizations(:respondo).id}/external_tickets.json",
             params: external_ticket_payload.merge(
               personal_access_token: {
                 name: personal_access_tokens(:default).name,
                 token: 'FSmksj0yku4eMg=='
               }
             ),
             as: :json
      end

      assert_response :ok
      assert_equal 'application/json; charset=utf-8', response.content_type
    end

    test 'POST create.json when token is authorized when payload is invalid' do
      organizations(:respondo).users << users(:john)

      assert_no_changes -> { Ticket.count }, from: 3 do
        post "/organizations/#{organizations(:respondo).id}/external_tickets.json",
             params: external_ticket_payload.merge(
               personal_access_token: {
                 name: personal_access_tokens(:default).name,
                 token: 'FSmksj0yku4eMg=='
               }
             ).except(:external_uid),
             as: :json
      end

      assert_response :ok
      assert_equal JSON.dump(error: 'Invalid payload schema.'), response.body
    end

    test 'POST create.json when user is not authorized' do
      post "/organizations/#{organizations(:respondo).id}/external_tickets.json",
           params: external_ticket_payload.merge(personal_access_token: {
                                                   name: personal_access_tokens(:default).name,
                                                   token: personal_access_tokens(:default).token
                                                 }),
           as: :json

      assert_response :forbidden
      assert_equal JSON.dump(error: 'not authorized'), response.body
    end

    test 'POST create.json when token is not authorized' do
      post "/organizations/#{organizations(:respondo).id}/external_tickets.json",
           params: external_ticket_payload.merge(personal_access_token: { name: personal_access_tokens(:default).name,
                                                                          token: 'bogus' }),
           as: :json

      assert_response :forbidden
      assert_equal JSON.dump(error: 'not authorized'), response.body
    end

    test 'POST create.json when token does not exist' do
      post "/organizations/#{organizations(:respondo).id}/external_tickets.json",
           params: external_ticket_payload.merge(personal_access_token: { name: 'bogus', token: 'bogus' }),
           as: :json

      assert_response :forbidden
      assert_equal JSON.dump(error: 'not authorized'), response.body
    end

    private

    def external_ticket_payload
      { external_uid: '123hello321world', content: 'This is content from the external ticket example.',
        parent_uid: 'external_ticket_parent_external_uid', created_at: 1.day.ago.utc,
        external_link: 'https://example.com',
        author: {
          external_uid: 'external_ticket_author_external_uid',
          username: 'best_username'
        },
        ticketable_attributes: {
          custom_provider: 'external'
        } }
    end
  end
end
