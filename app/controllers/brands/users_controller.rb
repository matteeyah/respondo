# frozen_string_literal: true

module Brands
  class UsersController < ApplicationController
    before_action :authenticate!
    before_action :authorize!

    def create
      brand.users << user

      redirect_to edit_brand_path(brand)
    end

    def destroy
      brand.users.delete(user)

      redirect_to edit_brand_path(brand)
    end

    private

    def user
      @user ||= User.find(params[:user_id] || params[:id])
    end
    helper_method :user
  end
end
