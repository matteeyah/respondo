# frozen_string_literal: true

module Mentions
  class RepliesController < ApplicationController
    def create
      @mention.respond_as(Current.user, reply_params[:content])
      @mention_hash = @mention.with_descendants_hash(::MentionsController::MENTION_RENDER_PRELOADS)
      @reply_model = Mention.new(parent: @mention)

      respond_to do |format|
        format.turbo_stream { render "mentions/show" }
        format.html { redirect_to mentions_path }
      end
    end

    private

    def reply_params
      params.require(:mention).permit(:content)
    end
  end
end
