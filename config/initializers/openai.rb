# frozen_string_literal: true

OpenAI.configure do |config|
  config.organization_id = Rails.application.credentials.openai.organization_id
  config.access_token = Rails.application.credentials.openai.api_key
end
