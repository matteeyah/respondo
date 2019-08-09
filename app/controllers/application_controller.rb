class ApplicationController < ActionController::Base
  # Required so devise can properly redirect in case of failure
  # Only because we're only using OAuth2
  def new_session_path(scope)
    new_user_session_path
  end
end
