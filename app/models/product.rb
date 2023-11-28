# frozen_string_literal: true

class Product < ApplicationRecord
  validates :name, presence: { allow_blank: false }
  validates :description, presence: { allow_blank: false }

  belongs_to :organization
end
