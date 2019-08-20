# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.attr_encrypted_encryption_key
    Rails.application.credentials.secret_key_base.first(32)
  end
end
