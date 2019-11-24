# frozen_string_literal: true

module Account
  extend ActiveSupport::Concern

  included do
    validates :external_uid, presence: { allow_blank: false }
    validates :email, presence: { allow_blank: false, allow_nil: true }

    attr_encrypted :token, key: attr_encrypted_encryption_key
    attr_encrypted :secret, key: attr_encrypted_encryption_key
  end

  def client
    case provider
    when 'twitter'
      twitter_client
    end
  end

  private

  def twitter_client
    @twitter_client ||=
      Clients::Twitter.new do |config|
        config.consumer_key        = ENV['TWITTER_API_KEY']
        config.consumer_secret     = ENV['TWITTER_API_SECRET']
        config.access_token        = token
        config.access_token_secret = secret
      end
  end
end
