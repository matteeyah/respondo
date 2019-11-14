# frozen_string_literal: true

class CreateComments < ActiveRecord::Migration[6.0]
  def change
    create_table :comments do |t|
      t.text :content, null: false

      t.references :user, index: true, null: false
      t.references :ticket, index: true, null: false

      t.timestamps
    end
  end
end
