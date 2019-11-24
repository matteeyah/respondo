# frozen_string_literal: true

class UserAccount < ApplicationRecord
  validates :external_uid, presence: { allow_blank: false }, uniqueness: { scope: :provider }
  validates :email, presence: { allow_blank: false, allow_nil: true }
  validates :provider, presence: true
  validates :provider, uniqueness: { scope: :user_id }

  enum provider: { google_oauth2: 0, twitter: 1, disqus: 2 }

  belongs_to :user

  attr_encrypted :token, key: attr_encrypted_encryption_key
  attr_encrypted :secret, key: attr_encrypted_encryption_key

  def self.from_omniauth(auth, current_user) # rubocop:disable Metrics/AbcSize
    find_or_initialize_by(external_uid: auth.uid, provider: auth.provider).tap do |account|
      account.email = auth.info.email

      account.token = auth.credentials.token
      account.secret = auth.credentials.secret

      account.user = current_user || account.user || User.new(name: auth.info.name)

      account.save
    end
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