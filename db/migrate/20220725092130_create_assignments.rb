# frozen_string_literal: true

class CreateAssignments < ActiveRecord::Migration[7.0]
  def change
    create_table :assignments do |t|
      t.references :user, index: true, null: false
      t.references :ticket, index: { unique: true }, null: false

      t.timestamps
    end
  end
end
