# frozen_string_literal: true

module Tickets
  class TagsController < ApplicationController
    before_action :set_tag, only: :destroy

    def create
      @tag = Tag.find_or_create_by!(name: tag_name)
      @ticket.tags << @tag unless @ticket.tags.include?(@tag)

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to tickets_path }
      end
    end

    def destroy
      @ticket.tags.delete(@tag)

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to tickets_path, status: :see_other }
      end
    end

    private

    def tag_name
      params.require(:tag).require(:name)
    end

    def set_tag
      @tag = @ticket.tags.find(params[:id])
    end
  end
end
