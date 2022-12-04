# frozen_string_literal: true

module Brands
  module Tickets
    class TagsController < ApplicationController
      def create
        @tag = new_tag
        @ticket = ticket
        @ticket.tags << @tag

        respond_to do |format|
          format.turbo_stream
          format.html { redirect_to brand_tickets_path(ticket.brand) }
        end
      end

      def destroy
        @ticket = ticket
        @tag = tag
        @ticket.tags.delete(@tag)

        respond_to do |format|
          format.turbo_stream
          format.html { redirect_to brand_tickets_path(ticket.brand), status: :see_other }
        end
      end

      private

      def tag_params
        params.require(:acts_as_taggable_on_tag).permit(:name)
      end

      def new_tag
        ActsAsTaggableOn::Tag.find_or_create_by(name: tag_params[:name])
      end

      def tag
        @tag ||= ticket.tags.find(params[:id])
      end
    end
  end
end
