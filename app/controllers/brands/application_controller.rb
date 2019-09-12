# frozen_string_literal: true

module Brands
  class ApplicationController < ApplicationController
    before_action :brand

    private

    def brand
      @brand ||= Brand.find(params[:brand_id] || params[:id])
    end

    def authorize!
      return if brand == current_brand

      redirect_back fallback_location: root_path, alert: 'You are not allowed to edit the Brand.'
    end
  end
end
