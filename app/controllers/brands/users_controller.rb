# frozen_string_literal: true

module Brands
  class UsersController < ApplicationController
    before_action :user
    before_action :authorize!

    def create
      brand.users << user
    end

    def destroy
      brand.users.delete(user)
    end

    private

    def user
      @user ||= User.find(params[:user_id] || params[:id])
    end
  end
end
