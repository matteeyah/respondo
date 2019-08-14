# frozen_string_literal: true

class Brand < ApplicationRecord
  has_many :users

  attr_encrypted :token, key: Rails.application.secrets.secret_key_base.first(32)
  attr_encrypted :secret, key: Rails.application.secrets.secret_key_base.first(32)

  def self.from_omniauth(auth, initial_user)
    where(external_uid: auth.uid).first_or_create do |brand|
      brand.nickname = auth.info.nickname
      brand.token = auth.credentials.token
      brand.secret = auth.credentials.secret
      brand.users << initial_user
    end
  end

  def self.new_with_session(params, session)
    super.tap do |brand|
      if (data = session['devise.twitter_data']&.dig('extra', 'raw_info'))
        brand.nickname = data['email'] if brand.nickname.blank?
      end
    end
  end

  def mentions
    twitter.mentions_timeline
  end

  private

  def twitter
    Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['TWITTER_API_KEY']
      config.consumer_secret     = ENV['TWITTER_API_SECRET']
      config.access_token        = token
      config.access_token_secret = secret
    end
  end
end
