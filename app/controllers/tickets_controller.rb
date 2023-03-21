# frozen_string_literal: true

class TicketsController < Tickets::ApplicationController
  include Pagy::Backend

  TICKET_RENDER_PRELOADS = [
    :author, :creator, :tags, :assignment, :replies,
    { organization: [:users], ticketable: %i[base_ticket source], internal_notes: [:creator] }
  ].freeze

  def index
    @pagy, tickets_relation = pagy(tickets)
    @tickets = tickets_relation.with_descendants_hash(TICKET_RENDER_PRELOADS)
  end

  def show
    @ticket_hash = ticket.with_descendants_hash(TICKET_RENDER_PRELOADS)
    @reply_model = Ticket.new(parent: ticket)
    @reply_model.content = generate_ai_response(ticket) if params[:ai]

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
    LoadNewTicketsJob.perform_later(current_user.organization)

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
    @ticket ||= current_user.organization.tickets.find(params[:ticket_id] || params[:id])
  end

  def parsed_query
    @parsed_query ||= begin
      key, value = params[:query].split(':')
      { key => value }
    end
  end

  def tickets
    query = params.slice(:status, :assignee, :tag)
    query = query.merge(parsed_query) if params[:query]
    TicketsQuery.new(current_user.organization.tickets, query).call
  end

  def update_params
    params.require(:ticket).permit(:status)
  end

  def ai_messages # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    [
      {
        role: 'system', content: <<~AI_WORKPLACE
          You work at a company called #{ticket.organization.screen_name}.
          #{ticket.organization.ai_guidelines}
        AI_WORKPLACE
      },
      {
        role: 'system', content: <<~AI_POSITION
          You are a social media manager and a support representative.
          Messages from the user are social media posts where someone mentions the company that you work for.
          You respond to those posts with a message.
        AI_POSITION
      },
      { role: 'user', content: "#{ticket.author.username}: #{ticket.content}" }
    ].tap do |messages|
      if params[:ai] != 'true'
        messages.insert(
          2,
          { role: 'system', content: "Generate a response using this prompt: #{params[:ai]}" }
        )
      end
    end
  end

  def generate_ai_response(_ticket)
    OpenAI::Client.new.chat(
      parameters: {
        model: 'gpt-3.5-turbo',
        messages: ai_messages, temperature: 0.7
      }
    ).dig('choices', 0, 'message', 'content').chomp.strip
  end
end
