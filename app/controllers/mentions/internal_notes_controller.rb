# frozen_string_literal: true

module Mentions
  class InternalNotesController < ApplicationController
    def create
      @internal_note = @mention.internal_notes.create(creator: Current.user, **note_params)

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to mentions_path }
      end
    end

    private

    def note_params
      params.require(:internal_note).permit(:content)
    end
  end
end
