# frozen_string_literal: true

class BrandsController < ApplicationController
  include Pagy::Backend

  before_action :brand, only: [:show]
  before_action :brands, only: [:index]

  def index; end

  def show; end

  private

  def brands
    @pagy, @brands = pagy(Brand.all)
  end

  def brand
    @brand ||= Brand.find(params[:id])
  end
end
