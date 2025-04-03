# frozen_string_literal: true

module Mentions
  class TagsController < ApplicationController
    before_action :set_tag, only: :destroy

    def create
      @tag = Tag.find_or_create_by!(name: tag_name)
      return head :ok if @mention.tags.include?(@tag)

      @mention.tags << @tag

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to mentions_path }
      end
    end

    def destroy
      @mention.tags.delete(@tag)

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to mentions_path, status: :see_other }
      end
    end

    private

    def tag_name
      params.require(:tag).require(:name)
    end

    def set_tag
      @tag = @mention.tags.find(params[:id])
    end
  end
end
