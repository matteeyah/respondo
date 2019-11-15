# frozen_string_literal: true

module Brands
  class TicketsController < ApplicationController
    include Pagy::Backend

    before_action :authenticate!, except: [:index]
    before_action :authorize!, except: %i[index reply]
    before_action :authorize_reply!, only: [:reply]

    def index
      status = params[:status].presence || 'open'
      query = params[:query]

      tickets = brand.tickets.where(status: status)
      tickets = if query
                  tickets.search(query)
                else
                  tickets.root
                end
      @pagy, tickets = pagy(tickets)
      @tickets = tickets.with_descendants_hash(:author, comments: [:user])
    end

    def reply
      begin
        tweet = client.reply(params[:response_text], ticket.external_uid)
        Ticket.from_tweet(tweet, brand)
        flash[:success] = 'Response was successfully submitted.'
      rescue Twitter::Error => e
        flash[:warning] = "Unable to create tweet.\n#{e.message}"
      end

      redirect_to brand_tickets_path(brand)
    end

    def comment
      comment = ticket.comments.create(content: params[:comment_text], user: current_user)

      if comment.persisted?
        flash[:success] = 'Comment was successfully submitted.'
      else
        flash[:warning] = 'Unable to create comment.'
      end

      redirect_to brand_tickets_path(brand)
    end

    def invert_status
      case ticket.status
      when 'open'
        ticket.solve!
      when 'solved'
        ticket.open!
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
      @ticket ||= brand.tickets.find(params[:ticket_id] || params[:id])
    end
  end
end
