# frozen_string_literal: true

class BrandAccount < ApplicationRecord
  include Accountable

  validates :external_uid, uniqueness: { scope: :provider }

  enum provider: { twitter: 0, disqus: 1, developer: 99 }

  belongs_to :brand

  def self.from_omniauth(auth, current_brand) # rubocop:disable Metrics/AbcSize
    find_or_initialize_by(external_uid: auth.uid, provider: auth.provider).tap do |account|
      account.email = auth.info.email

      account.token = auth.credentials.token
      account.secret = auth.credentials.secret

      account.brand = current_brand || Brand.new(screen_name: auth.info.nickname)

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
end
