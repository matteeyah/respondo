# frozen_string_literal: true

module Brands
  module Tickets
    class InternalNotesController < ApplicationController
      include Pundit::Authorization

      def create
        authorize(ticket.brand, :user_in_brand?)
        authorize(ticket.brand, :subscription?)

        @internal_note = create_note!

        respond_to do |format|
          format.turbo_stream
          format.html { redirect_to brand_ticket_path(ticket.brand, ticket) }
        end
      end

      private

      def note_params
        params.require(:internal_note).permit(:content)
      end

      def create_note!
        ticket.internal_notes.create(creator: current_user, **note_params)
      end
    end
  end
end
