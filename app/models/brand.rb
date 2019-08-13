# frozen_string_literal: true

class Brand < ApplicationRecord
  has_many :users
  devise :omniauthable, omniauth_providers: %i[twitter]

  def self.from_omniauth(auth)
    where(external_uid: auth.uid).first_or_create do |brand|
      brand.nickname = auth.info.nickname
    end
  end

  def self.new_with_session(params, session)
    super.tap do |brand|
      if (data = session['devise.twitter_data']&.dig('extra', 'raw_info'))
        brand.nickname = data['email'] if brand.nickname.blank?
      end
    end
  end
end
