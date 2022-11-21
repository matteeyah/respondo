# frozen_string_literal: true

module Brands
  module Tickets
    class AssignmentsController < ApplicationController
      def create
        authorize(ticket, :assign?)

        update_assignment!

        respond_to do |format|
          format.turbo_stream
          format.html { redirect_to brand_ticket_path(ticket.brand, ticket) }
        end
      end

      private

      def update_assignment!
        Assignment.find_or_initialize_by(ticket_id: ticket.id).tap do |assignment|
          assignment.user_id = assignment_params[:assignment][:user_id]
        end.save!
      end

      def assignment_params
        params.require(:ticket).permit(assignment: :user_id)
      end

      def pundit_user
        [current_user, brand]
      end
    end
  end
end
