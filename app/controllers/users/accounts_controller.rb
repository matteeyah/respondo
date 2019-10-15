# frozen_string_literal: true

module Users
  class AccountsController < ApplicationController
    before_action :authenticate!
    before_action :authorize!

    def destroy
      return unless account.destroy

      flash[:notice] = 'Successfully deleted the account.'

      redirect_back fallback_location: edit_user_path(current_user)
    end

    private

    def account
      @account ||= Account.find(params[:account_id] || params[:id])
    end
    helper_method :account
  end
end
