# frozen_string_literal: true

class OmniauthCallbacksController < ApplicationController
  def authenticate
    omniauth_hash = request.env['omniauth.auth']
    model = request.env['omniauth.params']['model']

    case model
    when 'user'
      authenticate_user(omniauth_hash)
    when 'brand'
      authenticate_brand(omniauth_hash)
    end

    redirect_to root_path
  end

  private

  def authenticate_user(auth_hash)
    account = Account.from_omniauth(auth_hash)

    flash[:notice] = if account.user.persisted?
                       'Successfully authenticated user.'
                     else
                       'Did not authenticate user.'
                     end

    sign_in(account.user) unless user_signed_in?
  end

  def authenticate_brand(auth_hash)
    return unless user_signed_in?

    brand = Brand.from_omniauth(auth_hash, current_user)

    flash[:notice] = if brand.persisted?
                       'Successfully authenticated brand.'
                     else
                       'Did not authenticate brand.'
                     end
  end
end
