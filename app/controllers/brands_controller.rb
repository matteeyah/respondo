# frozen_string_literal: true

class BrandsController < Brands::ApplicationController
  include Pagy::Backend

  before_action :authorize!, only: %i[edit add_user remove_user]

  def index
    @pagy, @brands = pagy(Brand.all)
  end

  def edit; end

  def refresh_tickets
    LoadTicketsJob.perform_now(@brand.id)
  end
end
