# frozen_string_literal: true

module Brands
  class TicketsController < ApplicationController
    before_action :ticket, except: %i[index refresh]
    before_action :authorize!, only: %i[refresh invert_status]
    before_action :authorize_reply!, only: [:reply]
    skip_before_action :brand, only: [:refresh]

    def index
      @open_tickets = brand.tickets.root.open
      @solved_tickets = brand.tickets.root.solved
    end

    def reply
      return unless client

      tweet = client.reply(params[:response_text], ticket.external_uid)
      Ticket.from_tweet(tweet, brand)
    end

    def invert_status
      case ticket.status
      when 'open'
        ticket.update(status: 'solved')
      when 'solved'
        ticket.update(status: 'open')
      end
    end

    def refresh
      LoadNewTweetsJob.perform_now(brand.id)
    end

    private

    def client
      @client ||= if current_brand == brand
                    brand.twitter
                  else
                    current_user.client_for(ticket.provider)
                  end
    end

    def authorize_reply!
      return if (current_brand == brand) || current_user&.client_for(ticket.provider)

      redirect_back fallback_location: root_path, alert: 'You are not allowed to reply to the Brand.'
    end

    def ticket
      @ticket ||= Ticket.find(params[:ticket_id] || params[:id])
    end
  end
end
