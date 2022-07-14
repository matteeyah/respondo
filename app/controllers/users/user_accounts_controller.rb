# frozen_string_literal: true

module Users
  class UserAccountsController < ApplicationController
    include Pundit::Authorization

    def destroy
      @account = account
      authorize(@account)

      @toast_message = remove_account!

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to edit_user_path(user), status: :see_other }
      end
    end

    private

    def remove_account!
      if user.accounts.count == 1
        'You can not remove your last account.'
      else
        @account.destroy
        'User account was successfully deleted.'
      end
    end

    def account
      @account ||= user.accounts.find(params[:user_account_id] || params[:id])
    end
  end
end
