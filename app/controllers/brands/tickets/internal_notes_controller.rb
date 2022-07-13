# frozen_string_literal: true

module Brands
  module Tickets
    class InternalNotesController < ApplicationController
      include Pundit::Authorization

      def create
        authorize(ticket.brand, :user_in_brand?)
        authorize(ticket.brand, :subscription?)

        ticket.internal_notes.create(creator: current_user, **note_params)

        redirect_to brand_ticket_path(ticket.brand, ticket)
      end

      private

      def note_params
        params.require(:internal_note).permit(:content)
      end
    end
  end
end
