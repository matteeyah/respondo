class SessionsController < ApplicationController
  def create
    case request.env['omniauth.auth'].provider
    when 'google_oauth2'
      login_user(request.env['omniauth.auth'])
    when 'twitter'
      login_brand(request.env['omniauth.auth'])
    end

    redirect_to root_path
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end

  private

  def login_user(auth_hash)
    user = User.from_omniauth(auth_hash)

    if user.persisted?
      session[:user_id] = user.id
      flash[:notice] = 'Successfully logged in user.'
    else
      flash[:notice] = 'Did not log in user.'
    end
  end

  def login_brand(auth_has)
    brand = Brand.from_omniauth(auth_hash, current_user)

    if brand.persisted?
      flash[:notice] = 'Successfully logged in brand.'
    else
      flash[:notice] = 'Did not log in brand.'
    end
  end
end
