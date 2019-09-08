# frozen_string_literal: true

class Brand < ApplicationRecord
  attr_encrypted :token, key: attr_encrypted_encryption_key
  attr_encrypted :secret, key: attr_encrypted_encryption_key

  has_many :users
  has_many :tickets

  ThreadedTweet = Struct.new(:id, :parent_id, :user, :text, :replies)

  class << self
    def from_omniauth(auth, initial_user)
      where(external_uid: auth.uid).first_or_create do |brand|
        brand.screen_name = auth.info.nickname
        brand.token = auth.credentials.token
        brand.secret = auth.credentials.secret
        brand.users << initial_user
      end
    end

    def new_with_session(params, session)
      super.tap do |brand|
        if (data = session['devise.twitter_data']&.dig('extra', 'raw_info'))
          brand.screen_name = data['email'] if brand.screen_name.blank?
        end
      end
    end
  end

  def new_mentions
    twitter.mentions_timeline(since: last_ticket_id)
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
