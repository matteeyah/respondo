# frozen_string_literal: true

class CreateInternalNotes < ActiveRecord::Migration[7.0]
  def change
    create_table :internal_notes do |t|
      t.text :content, null: false

      t.references :creator, index: true, null: false
      t.references :ticket, index: true, null: false

      t.timestamps
    end
  end
end
