# frozen_string_literal: true

unless Rails.env.test?
  OpenAI.configure do |config|
    config.access_token = Rails.application.credentials.openai.access_token
    config.organization_id = Rails.application.credentials.openai.organization_id
  end
end
