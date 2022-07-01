# frozen_string_literal: true

module Brands
  class BrandAccountsController < ApplicationController
    include Pundit::Authorization

    def destroy
      authorize(account)

      if brand.accounts.count == 1
        flash[:danger] = 'You can not remove your last account.'
      else
        account.destroy
        flash[:success] = 'Brand account was successfully deleted.'
      end

      redirect_to edit_brand_path(brand), status: :see_other
    end

    private

    def account
      @account ||= brand.accounts.find(params[:brand_account_id] || params[:id])
    end
  end
end
