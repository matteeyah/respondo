# frozen_string_literal: true

module Clients
  class Linkedin < Clients::ProviderClient
    def initialize(client_id, client_secret)
      super()

      @client_id = client_id
      @client_secret = client_secret
    end

    # TODO: Connect to real linkedin client and replace dummy data with real data
    def new_mentions(_last_ticket_identifier)
      []
    end

    private

    def linkedin_client
      @linkedin_client ||= Linkedin.new(@client_id, @client_secret)
    end

    def parse_response(api_response)
      {
        external_uid: api_response[:id], content: api_response[:content],
        created_at: api_response[:created_at], parent_uid: api_response[:parent_uid],
        author: { external_uid: api_response[:author][:id], username: api_response[:author][:username] }
      }
    end
  end
end
