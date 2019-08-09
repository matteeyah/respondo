# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Required so devise can properly redirect in case of failure
  # Only because we're only using OAuth2
  def new_session_path(scope) # rubocop:disable Lint/UnusedMethodArgument
    new_user_session_path
  end
end
