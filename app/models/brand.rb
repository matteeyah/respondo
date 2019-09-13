# frozen_string_literal: true

class Brand < ApplicationRecord
  validates :external_uid, presence: true, allow_blank: false
  validates :screen_name, presence: true, allow_blank: false

  attr_encrypted :token, key: attr_encrypted_encryption_key
  attr_encrypted :secret, key: attr_encrypted_encryption_key

  has_many :users
  has_many :tickets

  class << self
    def from_omniauth(auth, initial_user)
      find_or_create_by(external_uid: auth.uid) do |brand|
        brand.screen_name = auth.info.nickname
        brand.token = auth.credentials.token
        brand.secret = auth.credentials.secret
        brand.users << initial_user
      end
    end
  end

  def new_mentions
    twitter.mentions_timeline(since: last_ticket_id)
  end

  def reply(response_text, tweet_id)
    twitter.update(response_text, in_reply_to_status_id: tweet_id, auto_populate_reply_metadata: true)
  end

  private

  def last_ticket_id
    tickets.last&.external_uid
  end

  def twitter
    @twitter ||=
      Twitter::REST::Client.new do |config|
        config.consumer_key        = ENV['TWITTER_API_KEY']
        config.consumer_secret     = ENV['TWITTER_API_SECRET']
        config.access_token        = token
        config.access_token_secret = secret
      end
  end
end
