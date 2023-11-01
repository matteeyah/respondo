# frozen_string_literal: true

module Users
  class PersonalAccessTokensController < ApplicationController
    before_action :set_token, only: :destroy

    def create
      @token = build_personal_access_token
      @success = @token.save

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to profile_path }
      end
    end

    def destroy
      @token.destroy

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to profile_path, status: :see_other }
      end
    end

    private

    def set_token
      @token = current_user.personal_access_tokens.find(params[:id])
    end

    def build_personal_access_token
      current_user.personal_access_tokens.build(name: params[:name], token: SecureRandom.base64(10))
    end
  end
end
