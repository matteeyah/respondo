# frozen_string_literal: true

class BrandsController < Brands::ApplicationController
  include Pagy::Backend

  before_action :authenticate!, except: [:index]
  before_action :authorize!, except: [:index]

  def index
    query = params[:query]

    brands = if query.present?
               Brand.search(query)
             else
               Brand.all
             end
    @pagy, @brands = pagy(brands)
  end

  def edit
    @pagy, @brand_users = pagy(brand.users)
  end
end
