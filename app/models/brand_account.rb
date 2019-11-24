# frozen_string_literal: true

class BrandAccount < ApplicationRecord
  validates :external_uid, presence: { allow_blank: false }, uniqueness: { scope: :provider }
  validates :email, presence: { allow_blank: false, allow_nil: true }
  validates :provider, presence: true
  validates :provider, uniqueness: { scope: :brand_id }

  enum provider: { twitter: 0, disqus: 1 }

  belongs_to :brand

  attr_encrypted :token, key: attr_encrypted_encryption_key
  attr_encrypted :secret, key: attr_encrypted_encryption_key

  def self.from_omniauth(auth, current_brand) # rubocop:disable Metrics/AbcSize
    find_or_initialize_by(external_uid: auth.uid, provider: auth.provider).tap do |account|
      account.email = auth.info.email

      account.token = auth.credentials.token
      account.secret = auth.credentials.secret

      account.brand = current_brand || account.brand || Brand.new(screen_name: auth.info.nickname)

      account.save
    end
  end

  def new_mentions
    case provider
    when 'twitter'
      last_ticket_id = brand.tickets.twitter.last&.external_uid
      option_hash = { tweet_mode: 'extended' }
      option_hash[:since_id] = last_ticket_id if last_ticket_id
      twitter_client.mentions_timeline(option_hash)
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
