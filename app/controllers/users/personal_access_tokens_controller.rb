# frozen_string_literal: true

module Users
  class PersonalAccessTokensController < ApplicationController
    def create
      @token = build_personal_access_token
      @success = @token.save

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to profile_path }
      end
    end

    def destroy
      @token = personal_access_token
      @token.destroy

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to profile_path, status: :see_other }
      end
    end

    private

    def personal_access_token
      @personal_access_token ||= user.personal_access_tokens.find(params[:personal_access_token] || params[:id])
    end

    def build_personal_access_token
      user.personal_access_tokens.build(name: params[:name], token: SecureRandom.base64(10))
    end
  end
end
