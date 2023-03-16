# frozen_string_literal: true

module Tickets
  class TagsController < ApplicationController
    def create
      @ticket = ticket
      @ticket.tag_list.add(tag_params[:name])
      @ticket.save!
      @tag = new_tag
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to tickets_path }
      end
    end

    def destroy
      @ticket = ticket
      @tag = tag
      @ticket.tags.delete(@tag)

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to tickets_path, status: :see_other }
      end
    end

    private

    def tag_params
      params.require(:acts_as_taggable_on_tag).permit(:name)
    end

    def new_tag
      ActsAsTaggableOn::Tag.find_by(name: tag_params[:name])
    end

    def tag
      @tag ||= ticket.tags.find(params[:id])
    end
  end
end
