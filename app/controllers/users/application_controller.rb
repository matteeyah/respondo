# frozen_string_literal: true

module Users
  class ApplicationController < ::ApplicationController
    before_action :authorize_user!

    private

    def user
      @user ||= User.find(params[:user_id] || params[:id])
    end

    def authorize_user!
      return if current_user != user

      redirect_back fallback_location: root_path
    end
  end
end
