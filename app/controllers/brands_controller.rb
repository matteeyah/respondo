# frozen_string_literal: true

class BrandsController < ApplicationController
  before_action :brand, only: [:show]

  def show; end

  private

  def brand
    @brand ||= Brand.find(params[:id])
  end
end
