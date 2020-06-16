# frozen_string_literal: true

class TicketResponder
  attr_reader :ticket, :response, :user

  def initialize(ticket, response, user)
    @ticket = ticket
    @response = response
    @user = user
  end

  def call
    TicketCreator.new(ticket.provider, client_response, ticket.brand, user).call
  end

  private

  def client_response
    raw_response = client.reply(response, ticket.external_uid)
    ticket.external? ? JSON.parse(raw_response).deep_symbolize_keys : raw_response
  end

  def client
    if ticket.external?
      Clients::External.new(ticket.external_ticket.response_url, ticket.author.external_uid, ticket.author.username)
    else
      internal_client
    end
  end

  def internal_client
    if user.brand == ticket.brand
      user.brand.client_for_provider(ticket.provider)
    else
      user.client_for_provider(ticket.provider)
    end
  end
end
