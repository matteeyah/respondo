# frozen_string_literal: true

module Brands
  module Tickets
    class RepliesController < ApplicationController
      include Pundit::Authorization

      def create
        authorize(ticket.brand, :user_in_brand?)
        authorize(ticket.brand, :subscription?)

        respond!
        redirect_to brand_ticket_path(ticket.brand, ticket)
      rescue Twitter::Error
        # no-op
        redirect_to brand_ticket_path(ticket.brand, ticket)
      end

      private

      def reply_params
        params.require(:ticket).permit(:content)
      end

      def respond!
        TicketResponder.new(ticket, reply_params[:content], current_user).call
      end
    end
  end
end
