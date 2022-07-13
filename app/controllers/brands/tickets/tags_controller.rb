# frozen_string_literal: true

module Brands
  module Tickets
    class TagsController < ApplicationController
      include Pundit::Authorization

      def create
        authorize(ticket.brand, :user_in_brand?)

        ticket.tag_list.add(tag_params[:name])
        ticket.save

        redirect_to brand_ticket_path(ticket.brand, ticket)
      end

      def destroy
        authorize(ticket.brand, :user_in_brand?)

        ticket.tag_list.remove(tag.name)
        ticket.save

        redirect_to brand_ticket_path(ticket.brand, ticket), status: :see_other
      end

      private

      def tag_params
        params.require(:acts_as_taggable_on_tag).permit(:name)
      end

      def tag
        @tag ||= ticket.tags.find(params[:id])
      end
    end
  end
end
