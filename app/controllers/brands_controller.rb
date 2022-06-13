# frozen_string_literal: true

class BrandsController < Brands::ApplicationController
  include Pundit::Authorization
  include Pagy::Backend

  def edit
    authorize(brand)

    @pagy, @brand_users = pagy(brand.users)
  end

  def update
    authorize(brand)

    if brand.update(update_params)
      flash[:success] = 'Brand was successfully updated.'
    else
      flash[:danger] = 'Brand could not be updated.'
    end

    redirect_to edit_brand_path(brand)
  end

  private

  def brands
    BrandsQuery.new(Brand.all, params.slice(:query)).call
  end

  def update_params
    params.require(:brand).permit(:domain)
  end
end
