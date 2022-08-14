# frozen_string_literal: true

class TicketResponder < ApplicationService
  def initialize(ticket, response, user)
    super()

    @ticket = ticket
    @response = response
    @user = user
  end

  def call
    TicketCreator.new(
      @ticket.provider,
      @ticket.client.reply(@response, @ticket.external_uid),
      @ticket.source,
      @user
    ).call
  rescue Twitter::Error
    false
  end
end
