# frozen_string_literal: true

module ApplicationHelper
  def auth_twitter_path(params)
    "/auth/twitter?#{params.to_query}"
  end

  def auth_google_oauth2_path(params)
    "/auth/google_oauth2?#{params.to_query}"
  end
end
