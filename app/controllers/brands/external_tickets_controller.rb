# frozen_string_literal: true

module Brands
  class ExternalTicketsController < ApplicationController
    skip_before_action :verify_authenticity_token

    def create
      respond_to do |format|
        format.json do
          new_ticket = Ticket.from_external_ticket!(params, brand)
          render json: new_ticket
        end
      end
    end
  end
end
