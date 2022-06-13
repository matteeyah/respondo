# frozen_string_literal: true

module Users
  class PersonalAccessTokensController < ApplicationController
    include Pundit::Authorization

    def create
      pat = build_personal_access_token!
      authorize(pat)

      if pat.save
        flash[:success] = "User personal access token was successfully created. Please write it down: #{pat.token}"
      else
        flash[:warning] = "Unable to create personal access token.\n#{pat.errors.full_messages.join(', ')}."
      end

      redirect_to edit_user_path(user)
    end

    def destroy
      authorize(personal_access_token)

      personal_access_token.destroy

      flash[:success] = 'User personal access token was successfully deleted.'

      redirect_to edit_user_path(user)
    end

    private

    def personal_access_token
      @personal_access_token ||= user.personal_access_tokens.find(params[:personal_access_token] || params[:id])
    end

    def build_personal_access_token!
      user.personal_access_tokens.build(name: params[:name], token: SecureRandom.base64(10))
    end
  end
end
