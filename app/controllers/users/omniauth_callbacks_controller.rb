# frozen_string_literal: true

module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def google_oauth2
      @user = User.from_omniauth(request.env['omniauth.auth'])

      if @user.persisted?
        sign_in_and_redirect @user, event: :authentication

        set_flash_message(:notice, :success, kind: 'Google OAuth2')
      else
        session['devise.google_oauth2_data'] = request.env['omniauth.auth']
        set_flash_message(:notice, :failure, kind: 'Google OAuth2', reason: 'the authentication failed')
        redirect_to root_path
      end
    end
  end
end
