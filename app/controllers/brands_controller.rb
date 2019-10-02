# frozen_string_literal: true

class BrandsController < Brands::ApplicationController
  include Pagy::Backend

  before_action :authenticate!, only: [:index]
  before_action :authorize!, only: [:edit]

  def index
    @pagy, @brands = pagy(Brand.all)
  end

  def edit; end
end
