# frozen_string_literal: true

module Organizations
  class UsersController < ApplicationController
    include AuthorizesOrganizationMembership

    def create
      @user = external_user
      current_user.organization.users << @user

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to settings_path }
      end
    end

    def destroy
      @user = organization_user
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

    def organization_user
      @organization_user ||= current_user.organization.users.find(params[:user_id] || params[:id])
    end

    def remove_user!
      if current_user.organization.users.count > 1
        current_user.organization.users.delete(@user)
      else
        false
      end
    end

    def redirect_path
      # If user is removing self from organization, redirecting back results in
      # a redirect loop.
      organization_user == current_user ? root_path : settings_path
    end
  end
end
