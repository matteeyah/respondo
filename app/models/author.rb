# frozen_string_literal: true

class Author < ApplicationRecord
  has_many :tickets

  def self.from_twitter_user(twitter_user)
    first_or_create(external_uid: twitter_user.id) { |author| author.username = twitter_user.screen_name }
  end
end
