# frozen_string_literal: true

class OmniauthCallbacksController < ApplicationController
  def authenticate
    omniauth_hash = request.env['omniauth.auth']
    auth_params = request.env['omniauth.params']
    redirect_uri = auth_params['redirect_to'] || root_path

    case auth_params['model']
    when 'user'
      authenticate_user(omniauth_hash)
    when 'brand'
      authenticate_brand(omniauth_hash)
    end

    redirect_to redirect_uri
  end

  private

  def authenticate_user(auth_hash)
    account = Account.from_omniauth(auth_hash, current_user)

    if account.persisted?
      flash[:success] = 'User was successfully authenticated.'
      sign_in(account.user) unless user_signed_in?
    else
      flash[:danger] = "Could not authenticate user.\n#{account.errors.full_messages.join("\n")}"
    end
  end

  def authenticate_brand(auth_hash)
    unless user_signed_in?
      flash[:warning] = 'User is not signed in.'
      return
    end

    brand = Brand.from_omniauth(auth_hash)
    current_user.update(brand: brand)

    flash[:success] = 'Brand was successfully authenticated.'
  end
end
