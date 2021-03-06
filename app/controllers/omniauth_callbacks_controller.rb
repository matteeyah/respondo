# frozen_string_literal: true

class OmniauthCallbacksController < ApplicationController
  def authenticate
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

  private

  def authenticate_user(auth_hash)
    account = UserAccount.from_omniauth(auth_hash, current_user)

    if account.persisted?
      flash[:success] = 'User was successfully authenticated.'
      sign_in(account.user) unless user_signed_in?
    else
      flash[:danger] = "Could not authenticate user.\n#{account.errors.full_messages.join("\n")}"
    end
  end

  def authenticate_brand(auth_hash)
    return flash[:warning] = 'User is not signed in.' unless user_signed_in?

    account = BrandAccount.from_omniauth(auth_hash, current_brand)

    if account.persisted?
      flash[:success] = 'Brand was successfully authenticated.'
      current_user.update(brand: account.brand)
    else
      flash[:danger] = "Could not authenticate brand.\n#{account.errors.full_messages.join("\n")}"
    end
  end
end
