# frozen_string_literal: true

module Users
  class UserAccountsController < ApplicationController
    include Pundit::Authorization

    def destroy
      authorize(account)

      if user.accounts.count == 1
        flash[:danger] = 'You can not remove your last account.'
      else
        account.destroy
        flash[:success] = 'User account was successfully deleted.'
      end

      redirect_to edit_user_path(user), status: :see_other
    end

    private

    def account
      @account ||= user.accounts.find(params[:user_account_id] || params[:id])
    end
  end
end
