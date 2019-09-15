# frozen_string_literal: true

class Author < ApplicationRecord
  validates :external_uid, presence: true, allow_blank: false, uniqueness: { scope: :provider }
  validates :username, presence: true, allow_blank: false
  validates :provider, presence: true

  enum provider: { twitter: 0, google_oauth2: 1 }

  has_many :tickets, dependent: :restrict_with_error

  def self.from_twitter_user(twitter_user)
    find_or_create_by(external_uid: twitter_user.id, provider: 'twitter') { |author| author.username = twitter_user.screen_name }
  end
end
