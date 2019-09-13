# frozen_string_literal: true

class SessionsController < ApplicationController
  def create
    case request.env['omniauth.auth'].provider
    when 'google_oauth2'
      authenticate_user(request.env['omniauth.auth'])
    when 'twitter'
      authenticate_brand(request.env['omniauth.auth'])
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
      flash[:notice] = 'Successfully logged in user.'
    else
      flash[:notice] = 'Did not log in user.'
    end
  end

  def authenticate_brand(auth_hash)
    return unless user_signed_in?

    brand = Brand.from_omniauth(auth_hash, current_user)

    flash[:notice] = if brand.persisted?
                       'Successfully logged in brand.'
                     else
                       flash[:notice] = 'Did not log in brand.'
                     end
  end
end
