# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :create
  before_action :authenticate!, only: :destroy

  def create
    omniauth_hash = request.env['omniauth.auth']
    redirect_uri = request.env['omniauth.origin'] || root_path

    case request.env['omniauth.params']['state']
    when 'user'
      authenticate_user(omniauth_hash)
    when 'brand'
      authenticate_brand(omniauth_hash)
    end

    redirect_to redirect_uri
  end

  def destroy
    sign_out

    redirect_to login_path
  end

  private

  def authenticate!
    return unless current_user.nil?

    redirect_back fallback_location: login_path
  end

  def authenticate_user(auth_hash)
    account = UserAccount.from_omniauth(auth_hash, current_user)

    sign_in(account.user) if account.persisted? && current_user.nil?
  end

  def authenticate_brand(auth_hash)
    return if current_user.nil?

    account = BrandAccount.from_omniauth(auth_hash, current_brand)

    # This checks if the account was just created.
    LoadNewTicketsJob.perform_later(account.brand) if account.id_previously_changed?
    current_user.update(brand: account.brand) if account.persisted?
  end

  def account_errors(account)
    account.errors.full_messages.join("\n")
  end
end
