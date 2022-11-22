# frozen_string_literal: true

module Brands
  class ApplicationController < ::ApplicationController
    before_action :authorize_user!

    private

    def brand
      @brand ||= Brand.find(params[:brand_id] || params[:id])
    end

    def authorize_user!
      return if current_user.brand == brand

      redirect_back fallback_location: root_path
    end
  end
end
