# frozen_string_literal: true

module Users
  class PersonalAccessTokensController < ApplicationController
    include Pundit::Authorization

    def create
      @token = build_personal_access_token
      authorize(@token)

      @toast_message = @token.save ? success_message : failure_message

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to edit_user_path(user) }
      end
    end

    def destroy
      authorize(personal_access_token)
      @token = personal_access_token

      @token.destroy

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to edit_user_path(user), status: :see_other }
      end
    end

    private

    def personal_access_token
      @personal_access_token ||= user.personal_access_tokens.find(params[:personal_access_token] || params[:id])
    end

    def build_personal_access_token
      user.personal_access_tokens.build(name: params[:name], token: SecureRandom.base64(10))
    end

    def success_message
      "User personal access token was successfully created. Please write it down: #{@token.token}"
    end

    def failure_message
      "Unable to create personal access token.\n#{@token.errors.full_messages.join(', ')}."
    end
  end
end
