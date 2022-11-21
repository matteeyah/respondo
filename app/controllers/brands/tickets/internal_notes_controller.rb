# frozen_string_literal: true

module Brands
  module Tickets
    class InternalNotesController < ApplicationController
      def create
        authorize(ticket, :internal_note?)
        raise Pundit::NotAuthorizedError unless brand.subscribed?

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

      def pundit_user
        [current_user, brand]
      end
    end
  end
end
