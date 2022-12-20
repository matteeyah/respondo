# frozen_string_literal: true

class BrandsController < ApplicationController
  include Pagy::Backend

  def edit
    @pagy, @brand_users = pagy(current_user.brand.users)
    @brand = current_user.brand
  end

  def update
    @success = current_user.brand.update(update_params)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to settings_path }
    end
  end

  private

  def brands
    BrandsQuery.new(Brand.all, params.slice(:query)).call
  end

  def update_params
    params.require(:brand).permit(:domain)
  end
end
