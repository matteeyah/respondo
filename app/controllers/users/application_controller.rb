# frozen_string_literal: true

module Users
  class ApplicationController < ::ApplicationController
    before_action :user

    private

    def user
      @user ||= User.find(params[:user_id] || params[:id])
    end

    def authorize!
      return if user == current_user

      redirect_back fallback_location: root_path, alert: 'You are not allowed to edit the User.'
    end
  end
end
