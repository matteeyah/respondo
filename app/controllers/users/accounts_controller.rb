# frozen_string_literal: true

module Users
  class AccountsController < ApplicationController
    before_action :authenticate!
    before_action :authorize!

    def destroy
      if account.user.accounts.count == 1
        flash[:danger] = 'You can not remove your last account.'
      else
        account.destroy
        flash[:success] = 'User account was successfully deleted.'
      end

      redirect_to edit_user_path(user)
    end

    private

    def account
      @account ||= Account.find(params[:account_id] || params[:id])
    end
    helper_method :account
  end
end
