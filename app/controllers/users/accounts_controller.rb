# frozen_string_literal: true

module Users
  class AccountsController < ApplicationController
    before_action :authorize!, only: [:destroy]

    def destroy
      flash[:notice] = if account.destroy
                         'Successfully deleted the account.'
                       else
                         'There was a problem destroying the account.'
                       end
    end

    private

    def account
      @account ||= Account.find(params[:account_id] || params[:id])
    end
    helper_method :account
  end
end
