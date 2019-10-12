# frozen_string_literal: true

require './lib/token_verifier.rb'

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET']
  provider :twitter, ENV['TWITTER_API_KEY'], ENV['TWITTER_API_SECRET']
end

OmniAuth.config.allowed_request_methods = [:post]
OmniAuth.config.before_request_phase = TokenVerifier.new
