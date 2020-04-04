# frozen_string_literal: true

class InternalNote < ApplicationRecord
  validates :content, presence: { allow_blank: false }

  belongs_to :user
  belongs_to :ticket
end
