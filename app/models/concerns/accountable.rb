# frozen_string_literal: true

module Accountable
  extend ActiveSupport::Concern

  included do
    validates :external_uid, presence: { allow_blank: false }
    validates :email, presence: { allow_blank: false, allow_nil: true }

    attr_encrypted :token, key: attr_encrypted_encryption_key
    attr_encrypted :secret, key: attr_encrypted_encryption_key
  end

  private

  def twitter_client
    @twitter_client ||= Clients::Twitter.new(twitter_api_key, twitter_api_secret, token, secret)
  end

  def disqus_client
    @disqus_client ||= Clients::Disqus.new(disqus_public_key, disqus_secret_key, token)
  end

  def twitter_api_key
    @twitter_api_key ||= Rails.application.config.twitter.api_key
  end

  def twitter_api_secret
    @twitter_api_secret ||= Rails.application.config.twitter.api_secret
  end

  def disqus_public_key
    @disqus_public_key ||= Rails.application.config.disqus.public_key
  end

  def disqus_secret_key
    @disqus_secret_key ||= Rails.application.config.disqus.secret_key
  end
end
