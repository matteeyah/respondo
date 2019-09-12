# frozen_string_literal: true

class BrandsController < Brands::ApplicationController
  include Pagy::Backend

  before_action :authorize!, only: [:edit]
  skip_before_action :brand, only: [:index]

  def index
    @pagy, @brands = pagy(Brand.all)
  end

  def edit; end
end
