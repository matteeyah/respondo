# frozen_string_literal: true

module ApplicationHelper
  PROVIDER_HUMAN_NAMES = {
    "google_oauth2" => "Google",
    "entra_id" => "Microsoft Entra",
    "twitter" => "Twitter",
    "linkedin" => "LinkedIn"
  }.freeze

  def auth_provider_link(provider, html_options = {}, origin: nil, &block)
    params = { origin: }.compact.to_query
    button_to "/auth/#{provider}?#{params}", method: :post, "data-turbo" => false, **html_options, &block
  end

  def provider_human_name(provider)
    PROVIDER_HUMAN_NAMES[provider]
  end

  def safe_blank_link_to(text, url, html_options = {})
    link_to text, url, target: "_blank", rel: "noopener noreferrer", **html_options
  end

  def show_settings_collapse?
    action_name == "edit" && (controller_name == "organizations" || controller_name == "users")
  end
end
