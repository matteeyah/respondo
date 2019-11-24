# frozen_string_literal: true

class BrandAccount < ApplicationRecord
  include Account

  validates :external_uid, uniqueness: { scope: :provider }
  validates :provider, presence: true, uniqueness: { scope: :brand_id }
  enum provider: { twitter: 0, disqus: 1 }

  belongs_to :brand

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
      client.mentions_timeline(option_hash)
    end
  end
end
