# frozen_string_literal: true

module UsersHelper
  def provider_human_name(provider)
    case provider
    when 'twitter'
      'Twitter'
    when 'google_oauth2'
      'Google'
    end
  end
end
