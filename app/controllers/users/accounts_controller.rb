# frozen_string_literal: true

module Users
  class AccountsController < ApplicationController
    before_action :account
    before_action :authorize!, only: [:destroy]

    def destroy
      account.destroy
    end

    private

    def account
      @account ||= Account.find(params[:account_id] || params[:id])
    end
  end
end
