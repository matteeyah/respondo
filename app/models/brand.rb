# frozen_string_literal: true

class Brand < ApplicationRecord
  has_many :users

  def self.from_omniauth(auth, initial_user)
    where(external_uid: auth.uid).first_or_create do |brand|
      brand.nickname = auth.info.nickname
      brand.users << initial_user
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
