# frozen_string_literal: true

module Tickets
  class AssignmentsController < ApplicationController
    def create
      update_assignment!

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to tickets_path }
      end
    end

    private

    def update_assignment!
      Assignment.find_or_initialize_by(ticket_id: @ticket.id).tap do |assignment|
        user_id = assignment_params[:assignment][:user_id]
        if user_id.empty?
          Assignment.destroy(assignment.id)
        else
          assignment.user_id = user_id
          assignment.save!
        end
      end
    end

    def assignment_params
      params.require(:ticket).permit(assignment: :user_id)
    end
  end
end
