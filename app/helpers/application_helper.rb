# frozen_string_literal: true

module ApplicationHelper
  def auth_provider_link(text, provider, model, html_options = {})
    link_to text, auth_provider_path(provider, state: model), method: :post, **html_options
  end

  def provider_human_name(provider)
    case provider
    when 'twitter'
      'Twitter'
    when 'google_oauth2'
      'Google'
    when 'disqus'
      'Disqus'
    end
  end

  private

  def auth_provider_path(provider, params)
    path = case provider
           when 'twitter'
             '/auth/twitter'
           when 'google_oauth2'
             '/auth/google_oauth2'
           when 'disqus'
             '/auth/disqus'
           end

    "#{path}?#{params.to_query}"
  end
end
