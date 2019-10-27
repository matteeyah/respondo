# typed: strict
# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  extend T::Sig

  self.abstract_class = true

  sig { returns(String) }
  def self.attr_encrypted_encryption_key
    Rails.application.credentials.secret_key_base.first(32)
  end
end
