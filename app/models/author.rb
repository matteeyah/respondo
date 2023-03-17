# frozen_string_literal: true

class Author < ApplicationRecord
  validates :external_uid, presence: { allow_blank: false }, uniqueness: { scope: :provider }
  validates :username, presence: { allow_blank: false }
  validates :provider, presence: true

  enum provider: { external: 0, twitter: 1, disqus: 2, email: 3 }

  has_many :tickets, dependent: :restrict_with_error

  class << self
    def from_twitter_user!(twitter_user)
      find_or_initialize_by(external_uid: twitter_user.id, provider: 'twitter').tap do |author|
        author.username = twitter_user.screen_name

        author.save!
      end
    end

    def from_disqus_user!(disqus_user)
      find_or_initialize_by(external_uid: disqus_user[:id], provider: 'disqus').tap do |author|
        author.username = disqus_user[:username]

        author.save!
      end
    end

    def from_external_author!(external_author_json)
      find_or_initialize_by(external_uid: external_author_json[:external_uid], provider: 'external').tap do |author|
        author.username = external_author_json[:username]

        author.save!
      end
    end

    def from_email_author!(author_email)
      find_or_initialize_by(external_uid: author_email, provider: 'email').tap do |author|
        author.username = author_email

        author.save!
      end
    end
  end

  def external_link
    prefix = case provider
             when 'twitter'
               'https://twitter.com'
             when 'disqus'
               'https://disqus.com/by'
             end
    return unless prefix

    "#{prefix}/#{username}"
  end
end
