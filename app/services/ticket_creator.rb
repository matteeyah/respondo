# frozen_string_literal: true

class TicketCreator < ApplicationService
  def initialize(provider, body, source, user)
    super()

    @provider = provider
    @body = body
    @source = source
    @user = user
  end

  def call
    case @provider
    when 'twitter'
      Ticket.from_tweet!(@body, @source, @user)
    when 'disqus'
      Ticket.from_disqus_post!(@body, @source, @user)
    when 'external'
      Ticket.from_external_ticket!(@body, @source, @user)
    end
  end
end
