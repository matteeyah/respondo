# frozen_string_literal: true

module Brands
  class TicketsController < ApplicationController
    include Pundit::Authorization
    include Pagy::Backend

    def index
      authorize(brand, policy_class: TicketPolicy)
      @pagy, tickets_relation = pagy(tickets)
      @tickets = tickets_relation.with_descendants_hash(
        :author, :creator, :tags, :assignment, brand: [:users],
                                               ticketable: %i[base_ticket source], internal_notes: [:creator]
      )
      @brand = brand
    end

    def show
      authorize(ticket)

      @ticket_hash = Ticket.where(id: ticket.id).with_descendants_hash
      @action_form = params[:action_form]

      respond_to do |format|
        format.turbo_stream
        format.html
      end
    end

    def update
      authorize(ticket)

      ticket.update(update_params)

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to brand_tickets_path(brand, status: ticket.status_before_last_save) }
      end
    end

    def refresh
      authorize(Ticket)
      authorize(brand, :user_in_brand?)

      LoadNewTicketsJob.perform_later(brand.id)

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to brand_tickets_path(brand) }
      end
    end

    private

    def ticket
      @ticket ||= brand.tickets.find(params[:ticket_id] || params[:id])
    end

    def tickets
      TicketsQuery.new(brand.tickets, params.slice(:status, :query)).call
    end

    def update_params
      params.require(:ticket).permit(:status)
    end
  end
end
