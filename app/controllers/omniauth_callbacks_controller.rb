# frozen_string_literal: true

class OmniauthCallbacksController < ApplicationController
  def create
    omniauth_hash = request.env['omniauth.auth']
    action = request.env['omniauth.params']['action']

    case action
    when 'login'
      case omniauth_hash.provider
      when 'google_oauth2'
        authenticate_user(omniauth_hash)
      when 'twitter'
        authenticate_brand(omniauth_hash)
      end
    end

    redirect_to root_path
  end

  def destroy
    sign_out

    redirect_to root_path
  end

  private

  def authenticate_user(auth_hash)
    account = Account.from_omniauth(auth_hash)
    user = account.user || account.create_user(name: auth_hash.info.name)

    if user.persisted?
      sign_in(user)
      flash[:notice] = 'Successfully authenticated user.'
    else
      flash[:notice] = 'Did not authenticate user.'
    end
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
