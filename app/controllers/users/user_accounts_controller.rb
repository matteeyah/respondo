# frozen_string_literal: true

module Users
  class UserAccountsController < ApplicationController
    before_action :set_account, only: :destroy

    def destroy
      @success = @account.destroy

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to profile_path, status: :see_other }
      end
    end

    private

    def set_account
      @account = current_user.accounts.find(params[:id])
    end
  end
end
