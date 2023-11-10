# frozen_string_literal: true

class Assignment < ApplicationRecord
  validates :mention_id, uniqueness: true

  belongs_to :mention
  belongs_to :user
end
