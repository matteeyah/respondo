# frozen_string_literal: true

class CreateAuthors < ActiveRecord::Migration[7.0]
  def change
    create_table :authors do |t|
      t.string :external_uid, null: false
      t.string :username, null: false
      t.string :external_link, null: false

      t.integer :provider, null: false

      t.references :organization, null: false, foreign_key: true

      t.timestamps
    end

    add_index :authors, %i[external_uid provider organization_id], unique: true
  end
end
