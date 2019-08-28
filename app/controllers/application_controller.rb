# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :user_brand

  # Required so devise can properly redirect in case of failure
  # Only because we're only using OAuth2
  def new_session_path(scope) # rubocop:disable Lint/UnusedMethodArgument
    new_user_session_path
  end

  def user_brand
    @user_brand ||= current_user&.brand
  end
end
