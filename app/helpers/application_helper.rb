# frozen_string_literal: true

module ApplicationHelper
  PROVIDER_HUMAN_NAMES = {
    'twitter' => 'Twitter',
    'google_oauth2' => 'Google',
    'disqus' => 'Disqus'
  }.freeze

  PROVIDER_AUTH_PATHS = {
    'twitter' => '/auth/twitter',
    'google_oauth2' => '/auth/google_oauth2',
    'disqus' => '/auth/disqus'
  }.freeze

  def auth_provider_link(provider, model, html_options = {}, origin: nil, &block)
    params = { state: model, origin: origin }.compact
    button_to auth_provider_path(provider, **params), method: :post, 'data-turbo' => false, **html_options, &block
  end

  def provider_human_name(provider)
    PROVIDER_HUMAN_NAMES[provider]
  end

  def safe_blank_link_to(text, url, html_options = {})
    link_to text, url, target: '_blank', rel: 'noopener noreferrer', **html_options
  end

  def bi_icon(icon, custom_class = nil)
    sanitize("<i class='bi bi-#{icon} #{custom_class}'></i>")
  end

  private

  def auth_provider_path(provider, params)
    "#{PROVIDER_AUTH_PATHS[provider]}?#{params.to_query}"
  end
end
