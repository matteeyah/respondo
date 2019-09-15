# frozen_string_literal: true

class Account < ApplicationRecord
  validates :user_id, uniqueness: { scope: :provider }
  validates :external_uid, presence: true, allow_blank: false, uniqueness: { scope: :provider }
  validates :email, presence: true, allow_blank: false, allow_nil: true
  validates :provider, presence: true

  enum provider: { twitter: 0, google_oauth2: 1 }

  belongs_to :user

  attr_encrypted :token, key: attr_encrypted_encryption_key
  attr_encrypted :secret, key: attr_encrypted_encryption_key

  def self.from_omniauth(auth, existing_user = nil)
    find_or_initialize_by(external_uid: auth.uid, provider: auth.provider).tap do |account|
      account.token ||= auth.credentials.token
      account.secret ||= auth.credentials.secret
      account.email = auth.info.email if auth.info.email

      account.user ||= existing_user || account.build_user
      account.user.name ||= auth.info.name if auth.info.name

      account.save!
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
