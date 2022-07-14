# frozen_string_literal: true

module Brands
  class BrandAccountsController < ApplicationController
    include Pundit::Authorization

    def destroy
      @account = account
      authorize(@account)

      @toast_message = remove_account!

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to edit_brand_path(brand), status: :see_other }
      end
    end

    private

    def remove_account!
      if brand.accounts.count == 1
        'You can not remove your last account.'
      else
        @account.destroy
        'User account was successfully deleted.'
      end
    end

    def account
      @account ||= brand.accounts.find(params[:brand_account_id] || params[:id])
    end
  end
end
