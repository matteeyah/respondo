# frozen_string_literal: true

module Tickets
  class RepliesController < ApplicationController
    def create
      raise StandardError, 'Unauthorized' unless brand.subscribed?

      @ticket_hash = ticket_hash!

      respond_to do |format|
        format.turbo_stream { render 'tickets/show' }
        format.html { redirect_to tickets_path }
      end
    end

    private

    def reply_params
      params.require(:ticket).permit(:content)
    end

    def ticket_hash!
      ticket.respond_as(current_user, reply_params[:content])
      ticket.with_descendants_hash(Brands::TicketsController::TICKET_RENDER_PRELOADS)
    end
  end
end
