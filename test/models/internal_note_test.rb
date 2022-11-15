# frozen_string_literal: true

require 'test_helper'

class InternalNoteTest < ActiveSupport::TestCase
  test 'validates presence of content' do
    internal_note = internal_notes(:default)
    internal_note.content = nil

    assert_not internal_note.valid?
  end
end
