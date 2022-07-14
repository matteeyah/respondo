# frozen_string_literal: true

module Brands
  class UsersController < ApplicationController
    include Pundit::Authorization

    def create
      authorize([:brands, external_user])
      authorize(brand, :user_in_brand?)

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
      brand.users.delete(@user)

      respond_to do |format|
        format.turbo_stream
        format.html do
          # If user is removing self from brand, redirecting back results in a
          # redirect loop.
          redirect_to (brand_user == current_user ? root_path : edit_brand_path(brand)),
                      status: :see_other
        end
      end
    end

    private

    def external_user
      @external_user ||= User.find(params[:user_id] || params[:id])
    end

    def brand_user
      @brand_user ||= brand.users.find(params[:user_id] || params[:id])
    end
  end
end
