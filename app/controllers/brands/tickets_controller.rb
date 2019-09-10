# frozen_string_literal: true

module Brands
  class TicketsController < ApplicationController
    include Pagy::Backend

    before_action :authorize!, only: [:refresh]

    def index
      @pagy, @tickets = pagy(@brand.tickets.root)
    end

    def refresh
      LoadTicketsJob.perform_now(@brand.id)
    end
  end
end
