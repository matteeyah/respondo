# frozen_string_literal: true

module Brands
  class ApplicationController < ::ApplicationController
    private

    def brand
      @brand ||= Brand.find(params[:brand_id] || params[:id])
    end
  end
end
