# frozen_string_literal: true

class CreateAccounts < ActiveRecord::Migration[6.0]
  def change
    create_table :accounts do |t|
      t.string :external_uid, null: false
      t.string :email
      t.integer :provider, null: false, default: 0
      t.string :encrypted_token
      t.string :encrypted_token_iv, index: { unique: true }
      t.string :ecnrypted_secret
      t.string :encrypted_secret_iv, index: { unique: true }
      t.references :user, null: false
    end

    add_index :accounts, %i[external_uid provider], unique: true
  end
end
