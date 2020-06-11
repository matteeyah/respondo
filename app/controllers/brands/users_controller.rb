# frozen_string_literal: true

module Brands
  class UsersController < ApplicationController
    include Pundit

    def create
      authorize([:brands, external_user])
      authorize(brand, :user_in_brand?)

      brand.users << external_user

      redirect_to edit_brand_path(brand),
                  flash: { success: 'User was successfully added to the brand.' }
    end

    def destroy
      authorize([:brands, brand_user])

      brand.users.delete(brand_user)

      # If user is removing self from brand, redirecting back results in a
      # redirect loop.
      redirect_to (brand_user == current_user ? root_path : edit_brand_path(brand)),
                  flash: { success: 'User was successfully removed from the brand.' }
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
