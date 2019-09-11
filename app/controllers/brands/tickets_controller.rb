# frozen_string_literal: true

module Brands
  class TicketsController < ApplicationController
    before_action :ticket, except: %i[index refresh]
    before_action :authorize!, only: %i[refresh reply]

    def index
      @open_tickets = brand.tickets.root.open
      @solved_tickets = brand.tickets.root.solved
    end

    def reply
      tweet = brand.reply(params[:response_text], ticket.external_uid)
      Ticket.from_tweet(tweet, brand)
    end

    def refresh
      LoadNewTicketsJob.perform_now(brand.id)
    end

    private

    def ticket
      @ticket ||= Ticket.find(params[:ticket_id] || params[:id])
    end
  end
end
