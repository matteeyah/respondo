# frozen_string_literal: true

module Users
  class AccountsController < ApplicationController
    before_action :authorize!, only: [:destroy]

    def destroy
      account.destroy

      flash[:notice] = 'Successfully deleted account.'
    end

    private

    def account
      @account ||= Account.find(params[:account_id] || params[:id])
    end
    helper_method :account
  end
end
