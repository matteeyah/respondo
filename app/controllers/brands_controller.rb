# frozen_string_literal: true

class BrandsController < Brands::ApplicationController
  include Pagy::Backend

  before_action :authenticate!, except: [:index]
  before_action :authorize!, except: [:index]

  def index
    brands = Brand.where(Brand.arel_table[:screen_name].matches("%#{params[:query]}%"))
    @pagy, @brands = pagy(brands)
  end

  def edit
    @pagy, @brand_users = pagy(brand.users)
  end
end
