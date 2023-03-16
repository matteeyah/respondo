# frozen_string_literal: true

module Organizations
  class OrganizationAccountsController < ApplicationController
    include AuthorizesOrganizationMembership

    def destroy
      @account = account
      @account.destroy

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to settings_path, status: :see_other }
      end
    end

    private

    def account
      @account ||= current_user.organization.accounts.find(params[:organization_account_id] || params[:id])
    end
  end
end
