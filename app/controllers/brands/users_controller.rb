# frozen_string_literal: true

module Brands
  class UsersController < ApplicationController
    def create
      authorize(brand, policy_class: Brands::UserPolicy)

      @user = external_user
      brand.users << @user

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to edit_brand_path(brand) }
      end
    end

    def destroy
      authorize([:brands, brand_user])

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
      @brand_user ||= brand.users.find(params[:user_id] || params[:id])
    end

    def remove_user!
      if brand.users.count > 1
        brand.users.delete(@user)
      else
        false
      end
    end

    def redirect_path
      # If user is removing self from brand, redirecting back results in a
      # redirect loop.
      brand_user == current_user ? root_path : edit_brand_path(brand)
    end
  end
end
