# frozen_string_literal: true

module Brands
  class UsersController < ApplicationController
    def create
      @user = external_user
      current_user.brand.users << @user

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to settings_path }
      end
    end

    def destroy
      @user = brand_user
      @success = remove_user!

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to redirect_path, status: :see_other }
      end
    end

    private

    def external_user
      @external_user ||= User.find(params[:user_id] || params[:id])
    end

    def brand_user
      @brand_user ||= current_user.brand.users.find(params[:user_id] || params[:id])
    end

    def remove_user!
      if current_user.brand.users.count > 1
        current_user.brand.users.delete(@user)
      else
        false
      end
    end

    def redirect_path
      # If user is removing self from brand, redirecting back results in a
      # redirect loop.
      brand_user == current_user ? root_path : settings_path
    end
  end
end
