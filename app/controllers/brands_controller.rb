# frozen_string_literal: true

class BrandsController < ApplicationController
  include Pagy::Backend

  before_action :brand, except: [:index]
  before_action :user, only: %i[add_user remove_user]
  before_action :authorize!, only: %i[edit add_user remove_user]

  def index
    @pagy, @brands = pagy(Brand.all)
  end

  def show; end

  def edit; end

  def add_user
    @brand.users << @user
  end

  def remove_user
    @brand.users.delete(@user)
  end

  private

  def brand
    @brand ||= Brand.find(params[:id] || params[:brand_id])
  end

  def user
    @user ||= User.find(params[:user_id])
  end

  def authorize!
    return if @brand == @user_brand

    redirect_back fallback_location: root_path, alert: 'You are not allowed to edit the Brand.'
  end
end
