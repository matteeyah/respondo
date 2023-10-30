# frozen_string_literal: true

class Author < ApplicationRecord
  validates :external_uid, presence: { allow_blank: false }, uniqueness: { scope: :provider }
  validates :username, presence: { allow_blank: false }
  validates :provider, presence: true

  enum provider: { external: 0, twitter: 1, linkedin: 2, email: 3 }

  has_many :tickets, dependent: :restrict_with_error

  def self.from_client!(author_hash, provider)
    find_or_initialize_by(external_uid: author_hash[:external_uid], provider:).tap do |author|
      author.username = author_hash[:username]

      author.save!
    end
  end

  def external_link
    prefix = case provider
             when 'twitter'
              'https://x.com'
             when 'linkedin'
               'https://linkedin.com/in'
             end
    return unless prefix

    "#{prefix}/#{username}"
  end
end
