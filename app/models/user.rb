# frozen_string_literal: true

class User < ApplicationRecord
  devise :omniauthable, omniauth_providers: %i[google_oauth2 twitter]

  belongs_to :brand, optional: true

  class << self
    def from_omniauth(auth)
      where(external_uid: auth.uid).first_or_create do |user|
        user.email = auth.info.email
        user.name = auth.info.name
      end
    end

    def new_with_session(params, session)
      super.tap do |user|
        if (data = session['devise.google_oauth2_data']&.dig('extra', 'raw_info'))
          user.email = data['email'] if user.email.blank?
        end
      end
    end
  end
end
