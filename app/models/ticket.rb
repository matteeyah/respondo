# frozen_string_literal: true

class Ticket < ApplicationRecord
  belongs_to :author
  belongs_to :brand
end
