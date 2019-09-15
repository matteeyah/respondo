# frozen_string_literal: true

class CreateAccounts < ActiveRecord::Migration[6.0]
  def change
    create_table :accounts do |t|
      t.string :external_uid, null: false
      t.string :email
      t.integer :provider, null: false

      t.string :encrypted_token
      t.string :encrypted_token_iv, index: { unique: true }
      t.string :encrypted_secret
      t.string :encrypted_secret_iv, index: { unique: true }

      t.references :user, null: false

      t.timestamps
    end

    add_index :accounts, %i[user_id provider], unique: true
    add_index :accounts, %i[external_uid provider], unique: true
  end
end
