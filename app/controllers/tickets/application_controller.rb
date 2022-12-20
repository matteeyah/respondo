# frozen_string_literal: true

module Tickets
  class ApplicationController < ::ApplicationController
    private

    def ticket
      @ticket ||= Ticket.find(params[:ticket_id] || params[:id])
    end
  end
end
