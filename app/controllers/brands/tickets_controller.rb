# frozen_string_literal: true

module Brands
  class TicketsController < ApplicationController
    include Pagy::Backend

    before_action :authenticate!, except: %i[index show]
    before_action :check_subscription!, only: %i[reply internal_note invert_status]
    before_action :authorize!, except: %i[index reply show]
    before_action :authorize_reply!, only: [:reply]

    def index
      @pagy, tickets_relation = pagy(tickets)
      @tickets = tickets_relation.with_descendants_hash(:author, :user, internal_notes: [:user])
    end

    def show
      @ticket = ticket
    end

    def reply
      respond!
      flash[:success] = 'Response was successfully submitted.'
    rescue Twitter::Error => e
      flash[:warning] = "Unable to create tweet.\n#{e.message}"
    ensure
      redirect_to brand_tickets_path(brand)
    end

    def internal_note
      internal_note = ticket.internal_notes.create(content: params[:internal_note_text], user: current_user)

      if internal_note.persisted?
        flash[:success] = 'Internal note was successfully submitted.'
      else
        flash[:warning] = 'Unable to create internal note.'
      end

      redirect_to brand_tickets_path(brand)
    end

    def invert_status
      case ticket.status
      when 'open'
        ticket.solve!
      when 'solved'
        ticket.open!
      end

      redirect_to brand_tickets_path(brand),
                  flash: { success: 'Ticket status successfully changed.' }
    end

    def refresh
      LoadNewTicketsJob.perform_now(brand.id)

      redirect_to brand_tickets_path(brand),
                  flash: { success: 'Ticket refresh successfully initiated.' }
    end

    private

    def client # rubocop:disable Metrics/AbcSize
      @client ||= if ticket.external?
                    Clients::External.new(ticket.response_url, ticket.author.external_uid, ticket.author.username)
                  elsif current_brand == brand
                    current_brand.client_for_provider(ticket.provider)
                  else
                    current_user.client_for_provider(ticket.provider)
                  end
    end

    def authorize_reply!
      return if ticket.external?
      return if current_brand == brand
      return if current_user&.client_for_provider(ticket.provider)

      redirect_back fallback_location: root_path, flash: { warning: 'You are not allowed to reply to the ticket.' }
    end

    def ticket
      @ticket ||= brand.tickets.find(params[:ticket_id] || params[:id])
    end

    def tickets
      status = params[:status].presence || 'open'
      query = params[:query]

      filtered_tickets = brand.tickets.where(status: status)

      query.present? ? filtered_tickets.search(query) : filtered_tickets.root
    end

    def respond!
      response = client.reply(params[:response_text], ticket.external_uid)
      response = JSON.parse(response).deep_symbolize_keys if ticket.external?

      create_ticket!(ticket.provider, response)
    end

    def create_ticket!(provider, response)
      case provider
      when 'twitter'
        Ticket.from_tweet!(response, brand, current_user)
      when 'disqus'
        Ticket.from_disqus_post!(response, brand, current_user)
      when 'external'
        Ticket.from_external_ticket!(response, brand, current_user)
      end
    end

    def check_subscription!
      return if Flipper.enabled?(:skip_subscription_check)
      return if brand.subscription&.active?

      redirect_back fallback_location: root_path,
                    flash: {
                      warning: <<~WARNING_MESSAGE
                        You do not have an active subscription.
                        To be able to use outbound Respondo features please update your subscription in #{view_context.link_to('brand settings', edit_brand_path(brand))}.
                      WARNING_MESSAGE
                    }
    end
  end
end
