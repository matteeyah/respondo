# frozen_string_literal: true

module Brands
  class BrandAccountsController < ApplicationController
    def destroy
      @account = account
      @account.destroy

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to edit_brand_path(brand), status: :see_other }
      end
    end

    private

    def account
      @account ||= brand.accounts.find(params[:brand_account_id] || params[:id])
    end
  end
end
