# frozen_string_literal: true

class OrganizationAccount < ApplicationRecord
  validates :external_uid, presence: { allow_blank: false }, uniqueness: { scope: :provider }
  validates :provider, presence: true
  validates :email, presence: { allow_blank: false, allow_nil: true }
  validates :screen_name, presence: { allow_blank: false, allow_nil: true }

  enum provider: { twitter: 0, disqus: 1 }

  belongs_to :organization

  has_many :internal_tickets, class_name: 'InternalTicket', inverse_of: :source, foreign_key: :source_id,
                              dependent: :destroy
  has_many :tickets, through: :internal_tickets, source: :base_ticket

  encrypts :token
  encrypts :secret

  def self.from_omniauth(auth, current_organization) # rubocop:disable Metrics/AbcSize
    find_or_initialize_by(external_uid: auth.uid, provider: auth.provider).tap do |account|
      account.email = auth.info.email
      account.screen_name = auth.info.nickname

      account.token = auth.credentials.token
      account.secret = auth.credentials.secret

      account.organization = current_organization || account.organization || Organization.new(screen_name: auth.info.nickname)

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
    tickets.last&.external_uid
  end

  def last_disqus_ticket_identifier
    tickets.last&.created_at&.utc&.iso8601
  end

  def twitter_client
    @twitter_client ||= Clients::Twitter.new(twitter_api_key, twitter_api_secret, token, secret)
  end

  def disqus_client
    @disqus_client ||= Clients::Disqus.new(disqus_public_key, disqus_secret_key, token)
  end

  def twitter_api_key
    @twitter_api_key ||= Rails.application.credentials.dig(:twitter, :api_key)
  end

  def twitter_api_secret
    @twitter_api_secret ||= Rails.application.credentials.dig(:twitter, :api_secret)
  end

  def disqus_public_key
    @disqus_public_key ||= Rails.application.credentials.dig(:disuqs, :public_key)
  end

  def disqus_secret_key
    @disqus_secret_key ||= Rails.application.credentials.dig(:disqus, :secret_key)
  end
end
