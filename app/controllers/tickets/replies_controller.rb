# frozen_string_literal: true

module Tickets
  class RepliesController < ApplicationController
    def create
      @ticket.respond_as(current_user, reply_params[:content])
      @ticket_hash = @ticket.with_descendants_hash(::TicketsController::TICKET_RENDER_PRELOADS)

      respond_to do |format|
        format.turbo_stream { render 'tickets/show' }
        format.html { redirect_to tickets_path }
      end
    end

    private

    def reply_params
      params.require(:ticket).permit(:content)
    end
  end
end
