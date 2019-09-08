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
        brand.nickname = auth.info.nickname
        brand.token = auth.credentials.token
        brand.secret = auth.credentials.secret
        brand.users << initial_user
      end
    end

    def new_with_session(params, session)
      super.tap do |brand|
        if (data = session['devise.twitter_data']&.dig('extra', 'raw_info'))
          brand.nickname = data['email'] if brand.nickname.blank?
        end
      end
    end
  end

  def threaded_mentions
    # Filter root tweets
    tweets = mentions.select { |threaded_tweet| threaded_tweet.parent_id.nil? }

    # Filter tweets whose parent is not in `mentions`
    (mentions - tweets).each do |threaded_tweet|
      parent_tweet = tweets.find { |root_tweet| root_tweet.id == threaded_tweet.parent_id }
      next if parent_tweet

      tweets << threaded_tweet
    end

    # Thread tweets whose parent is in `mentions`
    (mentions - tweets).each do |threaded_tweet|
      parent_tweet = tweets.find { |root_tweet| root_tweet.id == threaded_tweet.parent_id }
      parent_tweet.replies << threaded_tweet
    end

    tweets
  end

  private

  def mentions
    twitter.mentions_timeline.map do |tweet|
      Brand::ThreadedTweet.new(
        tweet.id,
        # `Twitter::NullObject#presence` returned another `Twitter::NullObject`
        # https://github.com/sferik/twitter/issues/959
        tweet.in_reply_to_tweet_id.nil? ? nil : tweet.in_reply_to_tweet_id,
        tweet.user.screen_name,
        tweet.text,
        []
      )
    end
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
