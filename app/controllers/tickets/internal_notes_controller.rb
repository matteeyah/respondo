# frozen_string_literal: true

module Tickets
  class InternalNotesController < ApplicationController
    def create
      @internal_note = @ticket.internal_notes.create(creator: current_user, **note_params)

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to tickets_path }
      end
    end

    private

    def note_params
      params.require(:internal_note).permit(:content)
    end
  end
end
