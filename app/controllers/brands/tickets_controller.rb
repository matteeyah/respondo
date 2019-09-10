# frozen_string_literal: true

module Brands
  class TicketsController < ApplicationController
    include Pagy::Backend

    def index
      @pagy, @tickets = pagy(@brand.tickets.root)
    end
  end
end
