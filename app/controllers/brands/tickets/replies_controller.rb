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
        ticket.respond_as(current_user, reply_params[:content])
        Ticket.where(id: ticket.id).with_descendants_hash(Brands::TicketsController::TICKET_RENDER_PRELOADS)
      end
    end
  end
end
