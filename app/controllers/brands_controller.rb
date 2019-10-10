# frozen_string_literal: true

class BrandsController < Brands::ApplicationController
  include Pagy::Backend

  before_action :authenticate!, except: [:index]
  before_action :authorize!, except: [:index]

  def index
    @pagy, @brands = pagy(Brand.all)
  end

  def edit; end
end
