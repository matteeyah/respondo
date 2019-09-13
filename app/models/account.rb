# frozen_string_literal: true

class Account < ApplicationRecord
  validates :external_uid, presence: true, allow_blank: false, uniqueness: { scope: :provider }
  validates :email, presence: true, allow_blank: false

  enum provider: %i[twitter google_oauth2]

  belongs_to :user

  attr_encrypted :token, key: attr_encrypted_encryption_key
  attr_encrypted :secret, key: attr_encrypted_encryption_key

  def self.from_omniauth(auth, user_params = {})
    account = find_or_initialize_by(external_uid: auth.uid, provider: auth.provider) do |account|
      account.token = auth.credentials.token
      account.secret = auth.credentials.secret
    end

    account.tap do |account|
      account.email = auth.info.email
      account.create_user!(user_params)
      binding.pry
      account.save!
    end unless account.persisted?
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
      Twitter::REST::Client.new do |config|
        config.consumer_key        = ENV['TWITTER_API_KEY']
        config.consumer_secret     = ENV['TWITTER_API_SECRET']
        config.access_token        = token
        config.access_token_secret = secret
      end
  end
end
