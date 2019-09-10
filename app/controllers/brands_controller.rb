# frozen_string_literal: true

class BrandsController < Brands::ApplicationController
  include Pagy::Backend

  before_action :user, only: %i[add_user remove_user]
  before_action :authorize!, only: %i[edit add_user remove_user]

  def index
    @pagy, @brands = pagy(Brand.all)
  end

  def edit; end

  def add_user
    @brand.users << @user
  end

  def remove_user
    @brand.users.delete(@user)
  end

  def refresh_tickets
    LoadTicketsJob.perform_now(@brand.id)
  end

  private

  def user
    @user ||= User.find(params[:user_id])
  end
end
