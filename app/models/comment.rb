# frozen_string_literal: true

class Comment < ApplicationRecord
  validates :content, presence: true, allow_blank: false

  belongs_to :user
  belongs_to :ticket
end
