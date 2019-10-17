# frozen_string_literal: true

module Brands
  class TicketsController < ApplicationController
    include Pagy::Backend

    before_action :authenticate!, except: [:index]
    before_action :authorize!, only: %i[refresh invert_status]
    before_action :authorize_reply!, only: [:reply]

    def index
      status = params[:status] || 'open'
      @pagy, tickets = pagy(brand.tickets.root.where(status: status))
      @tickets = tickets.with_descendants_hash(:author)
    end

    def reply
      return unless client

      tweet = client.reply(params[:response_text], ticket.external_uid)
      Ticket.create_from_tweet(tweet, brand)

      redirect_to brand_tickets_path(brand),
                  flash: { success: 'Response has been successfully submitted.' }
    end

    def invert_status
      case ticket.status
      when 'open'
        ticket.update(status: 'solved')
      when 'solved'
        ticket.update(status: 'open')
      end

      redirect_to brand_tickets_path(brand),
                  flash: { success: 'Ticket status successfully changed.' }
    end

    def refresh
      LoadNewTweetsJob.perform_now(brand.id)

      redirect_to brand_tickets_path(brand),
                  flash: { success: 'Tickets refresh successfully initiated.' }
    end

    private

    def client
      @client ||= if current_brand == brand
                    brand.twitter
                  else
                    current_user.client_for_provider(ticket.provider)
                  end
    end

    def authorize_reply!
      return if (current_brand == brand) || current_user&.client_for_provider(ticket.provider)

      redirect_back fallback_location: root_path, flash: { warning: 'You are not allowed to reply to the ticket.' }
    end

    def ticket
      @ticket ||= Ticket.find(params[:ticket_id] || params[:id])
    end
    helper_method :ticket
  end
end
