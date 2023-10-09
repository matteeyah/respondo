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
  end
end
