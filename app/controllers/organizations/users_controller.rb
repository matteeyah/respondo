# frozen_string_literal: true

module Organizations
  class UsersController < ApplicationController
    include AuthorizesOrganizationMembership

    before_action :set_external_user, only: :create
    before_action :set_organization_user, only: :destroy

    def create
      Current.user.organization.users << @user

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to settings_path }
      end
    end

    def destroy
      @success = remove_user!

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to redirect_path, status: :see_other }
      end
    end

    private

    def set_external_user
      @user = User.find(params[:user_id])
    end

    def set_organization_user
      @user = Current.user.organization.users.find(params[:id])
    end

    def remove_user!
      if Current.user.organization.users.count > 1
        Current.user.organization.users.delete(@user)
      else
        false
      end
    end

    def redirect_path
      # If user is removing self from organization, redirecting back results in
      # a redirect loop.
      @user == Current.user ? root_path : settings_path
    end
  end
end
