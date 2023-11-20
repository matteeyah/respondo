# frozen_string_literal: true

module Clients
  class ProviderClient
    def new_mentions(_last_mention_identifier)
      raise NotImplementedError
    end

    def reply(_response_text, _external_uid)
      raise NotImplementedError
    end

    def delete(_external_uid)
      raise NotImplementedError
    end

    def posts(author_id)
      raise NotImplementedError
    end
  end
end
