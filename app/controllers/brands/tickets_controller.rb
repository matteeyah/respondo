# frozen_string_literal: true

module Brands
  class TicketsController < ApplicationController
    include Pagy::Backend

    protect_from_forgery except: [:create_external]

    before_action :authenticate!, except: %i[index create_external]
    before_action :authorize!, except: %i[index reply create_external]
    before_action :authorize_reply!, only: [:reply]

    def index
      @pagy, tickets_relation = pagy(tickets)
      @tickets = tickets_relation.with_descendants_hash(:author, :user, comments: [:user])
    end

    def create_external
      respond_to do |format|
        format.json do
          new_ticket = Ticket.from_external_ticket!(params, brand)
          render json: new_ticket
        end
      end
    end

    def reply
      create_ticket!
      flash[:success] = 'Response was successfully submitted.'
    rescue Twitter::Error => e
      flash[:warning] = "Unable to create tweet.\n#{e.message}"
    ensure
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

    def tickets
      status = params[:status].presence || 'open'
      query = params[:query]

      filtered_tickets = brand.tickets.where(status: status)

      query.present? ? filtered_tickets.search(query) : filtered_tickets.root
    end

    def create_ticket!
      Ticket.from_tweet!(
        client.reply(params[:response_text], ticket.external_uid),
        brand, current_user
      )
    end
  end
end
