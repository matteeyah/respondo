# frozen_string_literal: true

module Users
  class UserAccountsController < ApplicationController
    before_action :authenticate!
    before_action :authorize!

    def destroy
      if user.user_accounts.count == 1
        flash[:danger] = 'You can not remove your last account.'
      else
        account.destroy
        flash[:success] = 'User account was successfully deleted.'
      end

      redirect_to edit_user_path(user)
    end

    private

    def account
      @account ||= user.user_accounts.find(params[:user_account_id] || params[:id])
    end
  end
end
