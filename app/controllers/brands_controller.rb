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

  private

  def brands
    query = params[:query]

    if query.present?
      Brand.search(query)
    else
      Brand.all
    end
  end
end
