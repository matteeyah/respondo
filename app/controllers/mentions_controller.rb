# frozen_string_literal: true

class MentionsController < Mentions::ApplicationController
  include AuthorizesOrganizationMembership

  MENTION_RENDER_PRELOADS = [
    :author, :creator, :tags, :assignment, :replies, :source,
    { organization: [ :users ], internal_notes: [ :creator ] }
  ].freeze

  before_action :set_mention, only: %i[show update destroy]

  def index
    set_page_and_extract_portion_from(mentions)
    @mentions = @page.records.with_descendants_hash(MENTION_RENDER_PRELOADS)
  end

  def show
    @mention_hash = @mention.with_descendants_hash(MENTION_RENDER_PRELOADS)
    @reply_model = Mention.new(parent: @mention)
    @reply_model.content = @mention.generate_ai_response(params[:ai]) if params[:ai]

    respond_to do |format|
      format.turbo_stream
      format.html
    end
  end

  def update
    @mention.update(update_params)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to mentions_path(status: @mention.status_before_last_save) }
    end
  end

  def destroy
    @mention.client.delete(@mention.external_uid)
    @mention.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to mentions_path }
    end
  end

  private

  def set_mention
    @mention = Mention.find(params[:id])
  end

  def mentions
    query = params.slice(:status, :assignee, :tag)

    if params[:query]
      key, value = params[:query].split(":")
      query = query.merge(key => value)
    end

    MentionsQuery.new(current_user.organization.mentions, query).call
  end

  def update_params
    params.require(:mention).permit(:status)
  end
end
