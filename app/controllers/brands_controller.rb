# frozen_string_literal: true

class BrandsController < Brands::ApplicationController
  include Pagy::Backend

  before_action :authenticate!, except: [:index]
  before_action :authorize!, except: [:index]

  def index
    @pagy, @brands = pagy(brands)
  end

  def edit
    @pagy, @brand_users = pagy(brand.users)
  end

  def update
    if brand.update(update_params)
      flash[:success] = 'Brand was successfully updated.'
    else
      flash[:danger] = 'Brand could not be updated.'
    end

    redirect_to edit_brand_path(brand)
  end

  private

  def brands
    query = params[:query]

    if query.present?
      Brand.search(query)
    else
      Brand.all
    end
  end

  def update_params
    params.require(:brand).permit(:domain)
  end
end
