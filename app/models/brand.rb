# frozen_string_literal: true

class Brand < ApplicationRecord
  validates :external_uid, presence: { allow_blank: false }, uniqueness: true
  validates :screen_name, presence: { allow_blank: false }

  attr_encrypted :token, key: attr_encrypted_encryption_key
  attr_encrypted :secret, key: attr_encrypted_encryption_key

  has_many :users, dependent: :nullify
  has_many :tickets, dependent: :restrict_with_error

  class << self
    def from_omniauth(auth)
      find_or_initialize_by(external_uid: auth.uid).tap do |brand|
        brand.screen_name = auth.info.nickname

        brand.token = auth.credentials.token
        brand.secret = auth.credentials.secret

        brand.save!
      end
    end

    def search(query)
      where(arel_table[:screen_name].matches("%#{query}%"))
    end
  end

  def new_mentions
    option_hash = { tweet_mode: 'extended' }
    option_hash[:since_id] = last_ticket_id if last_ticket_id
    twitter.mentions_timeline(option_hash)
  end

  def twitter
    @twitter ||=
      Clients::Twitter.new do |config|
        config.consumer_key        = ENV['TWITTER_API_KEY']
        config.consumer_secret     = ENV['TWITTER_API_SECRET']
        config.access_token        = token
        config.access_token_secret = secret
      end
  end

  private

  def last_ticket_id
    tickets.last&.external_uid
  end
end
