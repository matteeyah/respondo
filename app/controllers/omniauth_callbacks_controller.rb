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
    user = current_user || User.new(name: auth_hash.info.name)
    user.accounts << Account.from_omniauth(auth_hash)
    user.save

    flash[:notice] = 'Successfully authenticated user.'

    sign_in(user) unless user_signed_in?
  end

  def authenticate_brand(auth_hash)
    return unless user_signed_in?

    brand = Brand.from_omniauth(auth_hash)
    current_user.update(brand: brand)

    flash[:notice] = 'Successfully authenticated brand.'
  end
end
