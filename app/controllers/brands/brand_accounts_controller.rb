# frozen_string_literal: true

module Brands
  class BrandAccountsController < ApplicationController
    before_action :authenticate!
    before_action :authorize!

    def destroy
      if brand.accounts.count == 1
        flash[:danger] = 'You can not remove your last account.'
      else
        account.destroy
        flash[:success] = 'Brand account was successfully deleted.'
      end

      redirect_to edit_brand_path(brand)
    end

    private

    def account
      @account ||= brand.accounts.find(params[:brand_account_id] || params[:id])
    end
  end
end
