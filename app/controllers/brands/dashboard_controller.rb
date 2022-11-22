# frozen_string_literal: true

module Brands
  class DashboardController < ApplicationController
    def index
      @newest_tickets = newest_tickets
      @new_count = new_tickets.count
      @open_count = current_user.brand.tickets.open.count
      @solved_count = current_user.brand.tickets.solved.count
      @unassigned_count = unassigned_tickets.count
    end

    private

    def new_tickets
      current_user.brand.tickets.open.where(created_at: Time.zone.today)
    end

    def unassigned_tickets
      current_user.brand.tickets.includes(:assignment).where(assignment: { ticket_id: nil })
    end

    def newest_tickets
      current_user.brand.tickets.includes(:author, ticketable: :source).order(created_at: :desc).take(3)
    end
  end
end
