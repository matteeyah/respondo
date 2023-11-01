# frozen_string_literal: true

module Organizations
  class OrganizationAccountsController < ApplicationController
    include AuthorizesOrganizationMembership

    before_action :set_account, only: :destroy

    def destroy
      @account.destroy

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to settings_path, status: :see_other }
      end
    end

    private

    def set_account
      @account = current_user.organization.accounts.find(params[:id])
    end
  end
end
