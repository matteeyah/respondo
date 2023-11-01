# frozen_string_literal: true

module Tickets
  class ApplicationController < ::ApplicationController
    include AuthorizesOrganizationMembership

    before_action :set_ticket

    private

    def set_ticket
      @ticket = Ticket.find(params[:ticket_id])
    end
  end
end
