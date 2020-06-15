# frozen_string_literal: true

class TicketCreator
  attr_reader :provider, :body, :brand, :user

  def initialize(provider, body, brand, user)
    @provider = provider
    @body = body
    @brand = brand
    @user = user
  end

  def call
    case provider
    when 'twitter'
      Ticket.from_tweet!(body, brand, user)
    when 'disqus'
      Ticket.from_disqus_post!(body, brand, user)
    when 'external'
      Ticket.from_external_ticket!(body, brand, user)
    end
  end
end
