# frozen_string_literal: true

class Tag < ApplicationRecord
  has_many :mention_tags, dependent: :destroy
  has_many :mentions, through: :mention_tags
end
