# frozen_string_literal: true

module Brands
  class TicketsController < ApplicationController
    include Pundit
    include Pagy::Backend

    def index
      @pagy, tickets_relation = pagy(tickets)
      @tickets = tickets_relation.with_descendants_hash(:author, :user, :brand, ticketable: [:base_ticket], internal_notes: [:user])
    end

    def show
      @ticket = ticket
    end

    def reply
      authorize(ticket)
      authorize(brand, :subscription?)

      respond!
      flash[:success] = 'Response was successfully submitted.'
      redirect_to brand_tickets_path(brand)
    rescue Twitter::Error => e
      flash[:warning] = "Unable to create tweet.\n#{e.message}"
      redirect_to brand_tickets_path(brand)
      # The double `#redirect_to` is required, since using `ensure` breaks
      # the `#authorize` logic.
    end

    def internal_note # rubocop:disable Metrics/AbcSize
      authorize(ticket)
      authorize(brand, :subscription?)

      internal_note = ticket.internal_notes.create(content: params[:internal_note_text], user: current_user)

      if internal_note.persisted?
        flash[:success] = 'Internal note was successfully submitted.'
      else
        flash[:warning] = 'Unable to create internal note.'
      end

      redirect_to brand_tickets_path(brand)
    end

    def invert_status
      authorize(ticket)
      authorize(brand, :subscription?)

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
      authorize(Ticket)
      authorize(brand, :user_in_brand?)

      LoadNewTicketsJob.perform_later(brand.id)

      redirect_to brand_tickets_path(brand),
                  flash: { success: 'Ticket refresh successfully initiated.' }
    end

    private

    def client # rubocop:disable Metrics/AbcSize
      @client ||= if ticket.external?
                    Clients::External.new(ticket.external_ticket.response_url, ticket.author.external_uid, ticket.author.username)
                  elsif current_brand == brand
                    current_brand.client_for_provider(ticket.provider)
                  else
                    current_user.client_for_provider(ticket.provider)
                  end
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

    def respond!
      response = client.reply(params[:response_text], ticket.external_uid)
      response = JSON.parse(response).deep_symbolize_keys if ticket.external?

      create_ticket!(ticket.provider, response)
    end

    def create_ticket!(provider, response)
      case provider
      when 'twitter'
        Ticket.from_tweet!(response, brand, current_user)
      when 'disqus'
        Ticket.from_disqus_post!(response, brand, current_user)
      when 'external'
        Ticket.from_external_ticket!(response, brand, current_user)
      end
    end
  end
end
