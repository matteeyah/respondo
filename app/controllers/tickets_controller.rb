# frozen_string_literal: true

class TicketsController < Tickets::ApplicationController
  include Pagy::Backend
  include AuthorizesOrganizationMembership

  TICKET_RENDER_PRELOADS = [
    :author, :creator, :tags, :assignment, :replies,
    { organization: [:users], ticketable: %i[base_ticket source], internal_notes: [:creator] }
  ].freeze

  before_action :set_ticket, only: %i[show update destroy permalink]

  def index
    @pagy, tickets_relation = pagy(tickets)
    @tickets = tickets_relation.with_descendants_hash(TICKET_RENDER_PRELOADS)
  end

  def show
    @ticket_hash = @ticket.with_descendants_hash(TICKET_RENDER_PRELOADS)
    @reply_model = Ticket.new(parent: @ticket)
    @reply_model.content = @ticket.generate_ai_response(params[:ai]) if params[:ai]

    respond_to do |format|
      format.turbo_stream
      format.html
    end
  end

  def update
    @ticket.update(update_params)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to tickets_path(status: @ticket.status_before_last_save) }
    end
  end

  def destroy
    @ticket.client.delete(@ticket.external_uid)
    @ticket.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to tickets_path }
    end
  end

  def refresh
    LoadNewTicketsJob.perform_later(current_user.organization)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to tickets_path }
    end
  end

  def permalink
    redirect_to @ticket.client.permalink(@ticket.external_uid), allow_other_host: true
  end

  private

  def set_ticket
    @ticket = Ticket.find(params[:id])
  end

  def tickets
    query = params.slice(:status, :assignee, :tag)

    if params[:query]
      key, value = params[:query].split(':')
      query.merge(key => value)
    end

    TicketsQuery.new(current_user.organization.tickets, query).call
  end

  def update_params
    params.require(:ticket).permit(:status)
  end
end
