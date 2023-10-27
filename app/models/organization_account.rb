# frozen_string_literal: true

class OrganizationAccount < ApplicationRecord
  validates :external_uid, presence: { allow_blank: false }, uniqueness: { scope: :provider }
  validates :provider, presence: true
  validates :email, presence: { allow_blank: false, allow_nil: true }
  validates :screen_name, presence: { allow_blank: false, allow_nil: true }

  enum provider: { twitter: 0, linkedin: 1 }

  belongs_to :organization

  has_many :internal_tickets, class_name: 'InternalTicket', inverse_of: :source, foreign_key: :source_id,
                              dependent: :destroy
  has_many :tickets, through: :internal_tickets, source: :base_ticket

  encrypts :token
  encrypts :secret

  def self.from_omniauth(auth, current_organization) # rubocop:disable Metrics/AbcSize
    find_or_initialize_by(external_uid: auth.uid, provider: auth.provider).tap do |account|
      account.email = auth.info.email
      account.screen_name = auth.info.nickname || auth.info.first_name

      account.token = auth.credentials.token
      account.secret = auth.credentials.secret

      account.organization = current_organization || account.organization ||
                             Organization.new(screen_name: auth.info.nickname)

      account.save
    end
  end

  def new_mentions
    last_ticket_identifier = case provider
                             when 'twitter'
                               last_x_ticket_identifier
                             end

    client.new_mentions(last_ticket_identifier)
  end

  def client
    case provider
    when 'twitter'
      x_client
    when 'linkedin'
      linkedin_client
    end
  end

  private

  def last_x_ticket_identifier
    tickets.last&.external_uid
  end

  def x_client
    @x_client ||= Clients::X.new(x_api_key, x_api_secret, token, secret)
  end

  def linkedin_client
    @linkedin_client ||= Clients::Linkedin.new(linkedin_client_id, linkedin_client_secret)
  end

  def x_api_key
    @x_api_key ||= Rails.application.credentials.x.api_key
  end

  def x_api_secret
    @x_api_secret ||= Rails.application.credentials.x.api_secret
  end

  def linkedin_client_id
    @linkedin_client_id ||= Rails.application.credentials.linkedin.client_id
  end

  def linkedin_client_secret
    @linkedin_client_secret ||= Rails.application.credentials.linkedin.client_secret
  end
end
