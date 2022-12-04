# frozen_string_literal: true

class OmniauthCallbacksController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!, only: :user

  def user
    account = UserAccount.from_omniauth(auth_hash, current_user)

    sign_in(account.user) if account.persisted? && current_user.nil?

    redirect_to(auth_origin || root_path)
  end

  def brand
    account = BrandAccount.from_omniauth(auth_hash, current_user.brand)

    # This checks if the account was just created.
    LoadNewTicketsJob.perform_later(account.brand) if account.id_previously_changed?
    current_user.update(brand: account.brand) if account.persisted?

    redirect_to(auth_origin || root_path)
  end

  private

  def auth_hash
    request.env['omniauth.auth']
  end

  def auth_origin
    request.env['omniauth.origin']
  end
end
