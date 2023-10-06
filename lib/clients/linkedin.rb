# frozen_string_literal: true

module Clients
  class Linkedin < Clients::ProviderClient
    def initialize(client_id, client_secret)
      super()

      @client_id = client_id
      @client_secret = client_secret
    end
  end

  def new_mentions(_last_ticket_identifier)
    logger.info 'a'
  end
end
