# frozen_string_literal: true

module Brands
  class DashboardController < ApplicationController
    include Pundit::Authorization

    def index
      authorize(brand, policy_class: TicketPolicy)

      @brand = current_brand
      @user = current_user
      @newest = newest_tickets.take(3)
      @open_count = current_brand.tickets.open.count
      @solved_count = current_brand.tickets.solved.count
      @new_count = new_tickets.count
    end

    private

    def new_tickets
      current_brand.tickets.open.where(created_at: Time.zone.today)
    end

    def newest_tickets
      current_brand.tickets.order(created_at: :desc)
    end
  end
end
