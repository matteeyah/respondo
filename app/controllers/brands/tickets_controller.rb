# frozen_string_literal: true

module Brands
  class TicketsController < ApplicationController
    include Pundit::Authorization
    include Pagy::Backend

    def index
      authorize(brand, policy_class: TicketPolicy)
      @pagy, tickets_relation = pagy(tickets)
      @tickets = tickets_relation.with_descendants_hash(
        :author, :creator, :brand, :tags, ticketable: [:base_ticket], internal_notes: [:creator]
      )
      @brand = brand
    end

    def show
      authorize(ticket)

      @ticket_hash = Ticket.where(id: ticket.id).with_descendants_hash
      @action_form = params[:action_form]
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

    def tickets
      TicketsQuery.new(brand.tickets, params.slice(:status, :query)).call
    end
  end
end
