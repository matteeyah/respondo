# frozen_string_literal: true

class Author < ApplicationRecord
  validates :external_uid, presence: { allow_blank: false }, uniqueness: { scope: :provider }
  validates :username, presence: { allow_blank: false }
  validates :provider, presence: true

  enum provider: { external: 0, twitter: 1 }

  has_many :tickets, dependent: :restrict_with_error

  class << self
    def from_twitter_user!(twitter_user)
      find_or_initialize_by(external_uid: twitter_user.id, provider: 'twitter').tap do |author|
        author.username = twitter_user.screen_name

        author.save!
      end
    end

    def from_external_author!(external_author_json)
      find_or_initialize_by(external_uid: external_author_json[:external_uid], provider: 'external').tap do |author|
        author.username = external_author_json[:username]

        author.save!
      end
    end
  end
end
