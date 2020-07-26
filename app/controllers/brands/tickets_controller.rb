# frozen_string_literal: true

module Brands
  class TicketsController < ApplicationController
    include Pundit
    include Pagy::Backend

    def index
      @pagy, tickets_relation = pagy(tickets)
      @tickets = tickets_relation.with_descendants_hash(
        :author, :creator, :brand, ticketable: [:base_ticket], internal_notes: [:creator]
      )
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

      internal_note = ticket.internal_notes.create(content: params[:internal_note_text], creator: current_user)

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

    def ticket
      @ticket ||= brand.tickets.find(params[:ticket_id] || params[:id])
    end

    def tickets
      TicketsQuery.new(brand.tickets, params.slice(:status, :query)).call
    end

    def respond!
      TicketResponder.new(ticket, params[:response_text], current_user).call
    end
  end
end
