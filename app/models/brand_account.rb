# frozen_string_literal: true

class BrandAccount < ApplicationRecord
  validates :external_uid, presence: { allow_blank: false }, uniqueness: { scope: :provider }
  validates :provider, presence: true
  validates :email, presence: { allow_blank: false, allow_nil: true }

  enum provider: { twitter: 0, disqus: 1, developer: 99 }

  belongs_to :brand

  encrypts :token
  encrypts :secret

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
    last_ticket_identifier = case provider
                             when 'twitter'
                               last_twitter_ticket_identifier
                             when 'disqus'
                               last_disqus_ticket_identifier
                             end

    client.new_mentions(last_ticket_identifier)
  end

  def client
    case provider
    when 'twitter'
      twitter_client
    when 'disqus'
      disqus_client
    end
  end

  private

  def last_twitter_ticket_identifier
    brand.tickets.twitter.last&.external_uid
  end

  def last_disqus_ticket_identifier
    brand.tickets.disqus.last&.created_at&.utc&.iso8601
  end

  def twitter_client
    @twitter_client ||= Clients::Twitter.new(twitter_api_key, twitter_api_secret, token, secret)
  end

  def disqus_client
    @disqus_client ||= Clients::Disqus.new(disqus_public_key, disqus_secret_key, token)
  end

  def twitter_api_key
    @twitter_api_key ||= Rails.application.config.x.twitter.api_key
  end

  def twitter_api_secret
    @twitter_api_secret ||= Rails.application.config.x.twitter.api_secret
  end

  def disqus_public_key
    @disqus_public_key ||= Rails.application.config.x.disqus.public_key
  end

  def disqus_secret_key
    @disqus_secret_key ||= Rails.application.config.x.disqus.secret_key
  end
end
