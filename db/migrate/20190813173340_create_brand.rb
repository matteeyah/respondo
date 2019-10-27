# typed: true
# frozen_string_literal: true

class CreateBrand < ActiveRecord::Migration[6.0]
  def change
    create_table :brands do |t|
      t.string :external_uid, null: false, index: { unique: true }
      t.string :screen_name, null: false

      t.string :encrypted_token
      t.string :encrypted_token_iv, index: { unique: true }
      t.string :encrypted_secret
      t.string :encrypted_secret_iv, index: { unique: true }

      t.timestamps
    end

    add_reference :users, :brand, index: true, null: true
  end
end
