# frozen_string_literal: true

module ApplicationHelper
  def auth_provider_link(text, provider, model, html_options = {})
    link_to text, auth_provider_path(provider, model: model, redirect_to: request.path), method: :post, **html_options
  end

  private

  def auth_provider_path(provider, params)
    path = case provider
           when 'twitter'
             '/auth/twitter'
           when 'google_oauth2'
             '/auth/google_oauth2'
           end

    "#{path}?#{params.to_query}"
  end
end
