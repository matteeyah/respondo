# frozen_string_literal: true

module Brands
  class TicketsController < ApplicationController
    include Pundit::Authorization
    include Pagy::Backend

    def index
      @pagy, tickets_relation = pagy(tickets)
      @tickets = tickets_relation.with_descendants_hash(
        :author, :creator, :brand, ticketable: [:base_ticket], internal_notes: [:creator]
      )
      @brand = brand
    end

    def show
      @ticket_hash = Ticket.where(id: ticket.id).with_descendants_hash
      @action_form = params[:action_form]
    end

    def reply
      authorize(ticket)
      authorize(brand, :subscription?)

      respond!
      flash[:success] = 'Response was successfully submitted.'

      @ticket_hash = ticket_hash
      render :show
    rescue Twitter::Error => e
      flash[:warning] = "Unable to create tweet.\n#{e.message}"
      @ticket_hash = ticket_hash
      render :show
      # The double `#redirect_to` is required, since using `ensure` breaks
      # the `#authorize` logic.
    end

    def internal_note
      authorize(ticket)
      authorize(brand, :subscription?)

      if create_note!.persisted?
        flash[:success] = 'Internal note was successfully submitted.'
      else
        flash[:warning] = 'Unable to create internal note.'
      end

      @ticket_hash = ticket_hash
      render :show
    end

    def invert_status
      authorize(ticket)
      authorize(brand, :subscription?)

      case ticket.status
      when 'open'
        ticket.solve!
      when 'solved'
        ticket.reopen!
      end

      redirect_to brand_tickets_path(brand, status: ticket.status_before_last_save),
                  flash: { success: 'Ticket status successfully changed.' }
    end

    def refresh
      authorize(Ticket)
      authorize(brand, :user_in_brand?)

      LoadNewTicketsJob.perform_later(brand.id)

      flash = { success: 'Tickets will be loaded asynchronously. Refresh the page to see new tickets once they load.' }
      redirect_to brand_tickets_path(brand), flash:
    end

    private

    def ticket
      @ticket ||= brand.tickets.find(params[:ticket_id] || params[:id])
    end

    def ticket_hash
      @ticket_hash ||= Ticket.where(id: ticket.id).with_descendants_hash
    end

    def tickets
      TicketsQuery.new(brand.tickets, params.slice(:status, :query)).call
    end

    def respond!
      TicketResponder.new(ticket, params[:response_text], current_user).call
    end

    def create_note!
      ticket.internal_notes.create(content: params[:internal_note_text], creator: current_user)
    end
  end
end
