# frozen_string_literal: true

module Brands
  class ApplicationController < ::ApplicationController
    private

    def brand
      @brand ||= Brand.find(params[:brand_id] || params[:id])
    end
    helper_method :brand

    def authorize!
      return if brand == current_brand

      redirect_back fallback_location: root_path, flash: { warning: 'You are not allowed to edit the brand.' }
    end
  end
end
