# frozen_string_literal: true

module Brands
  module Tickets
    class RepliesController < ApplicationController
      include Pundit::Authorization

      def create
        authorize(ticket.brand, :user_in_brand?)
        authorize(ticket.brand, :subscription?)

        @ticket_hash = ticket_hash!

        respond_to do |format|
          format.turbo_stream { render 'brands/tickets/show' }
          format.html { redirect_to brand_ticket_path(ticket.brand, ticket) }
        end
      end

      private

      def reply_params
        params.require(:ticket).permit(:content)
      end

      def ticket_hash!
        TicketResponder.new(ticket, reply_params[:content], current_user).call
        Ticket.where(id: ticket.id).with_descendants_hash(
          :author, :creator, :tags, :assignment,
          brand: [:users], ticketable: %i[base_ticket source], internal_notes: [:creator]
        )
      end
    end
  end
end
