# frozen_string_literal: true

module Brands
  module Tickets
    class AssignmentsController < ApplicationController
      include Pundit::Authorization

      def create
        authorize(ticket.brand, :user_in_brand?)

        update_assignment!

        redirect_to brand_ticket_path(ticket.brand, ticket)
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
    end
  end
end
