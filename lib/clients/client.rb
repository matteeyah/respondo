# frozen_string_literal: true

module Clients
  class Client
    def new_mentions(_last_ticket_identifier)
      raise NotImplementedError
    end

    def reply(_response_text, _external_uid)
      raise NotImplementedError
    end
  end
end
