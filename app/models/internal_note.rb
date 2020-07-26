# frozen_string_literal: true

class InternalNote < ApplicationRecord
  validates :content, presence: { allow_blank: false }

  belongs_to :creator, class_name: 'User'
  belongs_to :ticket
end
