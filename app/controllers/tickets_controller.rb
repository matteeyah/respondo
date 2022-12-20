# frozen_string_literal: true

class TicketsController < ApplicationController
  include Pagy::Backend

  TICKET_RENDER_PRELOADS = [
    :author, :creator, :tags, :assignment,
    { brand: [:users], ticketable: %i[base_ticket source], internal_notes: [:creator] }
  ].freeze

  def index
    @pagy, tickets_relation = pagy(tickets)
    @tickets = tickets_relation.with_descendants_hash(TICKET_RENDER_PRELOADS)
  end

  def show
    @ticket_hash = ticket.with_descendants_hash(TICKET_RENDER_PRELOADS)

    respond_to do |format|
      format.turbo_stream
      format.html
    end
  end

  def update
    ticket.update(update_params)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to tickets_path(status: ticket.status_before_last_save) }
    end
  end

  def destroy
    ticket.client.delete(ticket.external_uid)
    ticket.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to tickets_path }
    end
  end

  def refresh
    LoadNewTicketsJob.perform_later(current_user.brand.id)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to tickets_path }
    end
  end

  def permalink
    redirect_to ticket.client.permalink(ticket.external_uid), allow_other_host: true
  end

  private

  def ticket
    @ticket ||= current_user.brand.tickets.find(params[:ticket_id] || params[:id])
  end

  def tickets
    TicketsQuery.new(current_user.brand.tickets, params.slice(:status, :query)).call
  end

  def update_params
    params.require(:ticket).permit(:status)
  end
end
