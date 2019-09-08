# frozen_string_literal: true

class Author < ApplicationRecord
  validates :external_uid, presence: true, allow_blank: false
  validates :username, presence: true, allow_blank: false

  has_many :tickets

  def self.from_twitter_user(twitter_user)
    find_or_create_by(external_uid: twitter_user.id) { |author| author.username = twitter_user.screen_name }
  end
end
