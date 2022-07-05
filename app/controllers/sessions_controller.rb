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

    redirect_back fallback_location: login_path, flash: { warning: 'You are not signed in.' }
  end

  def authenticate_user(auth_hash)
    account = UserAccount.from_omniauth(auth_hash, current_user)

    if account.persisted?
      sign_in(account.user) if current_user.nil?
    else
      flash[:danger] = "Could not authenticate user.\n#{account_errors(account)}"
    end
  end

  def authenticate_brand(auth_hash)
    return flash[:warning] = 'User is not signed in.' if current_user.nil?

    account = BrandAccount.from_omniauth(auth_hash, current_brand)

    if account.persisted?
      current_user.update(brand: account.brand)
    else
      flash[:danger] = "Could not authenticate brand.\n#{account_errors(account)}"
    end
  end

  def account_errors(account)
    account.errors.full_messages.join("\n")
  end
end
