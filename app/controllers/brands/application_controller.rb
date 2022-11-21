# frozen_string_literal: true

module Brands
  class ApplicationController < ::ApplicationController
    private

    def brand
      @brand ||= Brand.find(params[:brand_id] || params[:id])
    end

    def pundit_user
      [current_user, brand]
    end
  end
end
