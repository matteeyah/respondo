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
    @twitter_client ||= Clients::Twitter.new(ENV['TWITTER_API_KEY'], ENV['TWITTER_API_SECRET'], token, secret)
  end

  def disqus_client
    @disqus_client ||= Clients::Disqus.new(ENV['DISQUS_PUBLIC_KEY'], ENV['DISQUS_SECRET_KEY'], token)
  end
end
