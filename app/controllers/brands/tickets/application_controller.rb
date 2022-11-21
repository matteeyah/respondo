# frozen_string_literal: true

module Brands
  module Tickets
    class ApplicationController < ::Brands::ApplicationController
      private

      def ticket
        @ticket ||= Ticket.find(params[:ticket_id] || params[:id])
      end

      def pundit_user
        [current_user, [brand, ticket]]
      end
    end
  end
end
