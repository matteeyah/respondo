# frozen_string_literal: true

class Account < ApplicationRecord
  validates :external_uid, presence: true, allow_blank: false, uniqueness: { scope: :provider }
  validates :email, presence: true, allow_blank: false, allow_nil: true
  validates :provider, presence: true
  validates :user_id, uniqueness: { scope: :provider }

  enum provider: { twitter: 0, google_oauth2: 1 }

  belongs_to :user

  attr_encrypted :token, key: attr_encrypted_encryption_key
  attr_encrypted :secret, key: attr_encrypted_encryption_key

  def self.from_omniauth(auth)
    find_or_initialize_by(external_uid: auth.uid, provider: auth.provider).tap do |account|
      account.email = auth.info.email

      account.token = auth.credentials.token
      account.secret = auth.credentials.secret

      account.save! if account.persisted?
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
