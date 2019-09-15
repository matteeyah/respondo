# frozen_string_literal: true

class CreateAuthors < ActiveRecord::Migration[6.0]
  def change
    create_table :authors do |t|
      t.string :external_uid, null: false
      t.integer :provider, null: false
      t.string :username, null: false

      t.timestamps
    end

    add_index :authors, %i[external_uid provider], unique: true
  end
end
