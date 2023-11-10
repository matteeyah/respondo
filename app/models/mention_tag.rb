# frozen_string_literal: true

class MentionTag < ApplicationRecord
  belongs_to :mention
  belongs_to :tag
end
