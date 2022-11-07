# frozen_string_literal: true

class BrandsController < Brands::ApplicationController
  include Pundit::Authorization
  include Pagy::Backend

  def edit
    authorize(brand)

    @pagy, @brand_users = pagy(brand.users)
    @brand = brand
  end

  def update
    authorize(brand)

    @success = brand.update(update_params)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to edit_brand_path(current_brand) }
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
