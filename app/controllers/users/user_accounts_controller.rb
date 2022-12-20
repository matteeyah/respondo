# frozen_string_literal: true

module Users
  class UserAccountsController < ApplicationController
    def destroy
      @account = account
      @success = @account.destroy

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to profile_path, status: :see_other }
      end
    end

    private

    def account
      @account ||= current_user.accounts.find(params[:user_account_id] || params[:id])
    end
  end
end
