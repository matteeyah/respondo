# frozen_string_literal: true

class UserAccount < ApplicationRecord
  include Accountable

  validates :external_uid, uniqueness: { scope: :provider }
  validates :provider, presence: true, uniqueness: { scope: :user_id }

  enum provider: { google_oauth2: 0, twitter: 1, disqus: 2 }

  belongs_to :user

  class << self
    def from_omniauth(auth, current_user) # rubocop:disable Metrics/AbcSize
      find_or_initialize_by(external_uid: auth.uid, provider: auth.provider).tap do |account|
        account.email = auth.info.email

        account.token = auth.credentials.token
        account.secret = auth.credentials.secret

        account.user = current_user || account.user || User.new(name: auth.info.name)
        account.user.brand = find_brand(account.email)

        account.save
      end
    end

    private

    def find_brand(user_email)
      return unless user_email

      user_domain = user_email.split('@').last
      Brand.find_by(domain: user_domain)
    end
  end

  def client
    case provider
    when 'twitter'
      twitter_client
    when 'disqus'
      disqus_client
    end
  end
end
