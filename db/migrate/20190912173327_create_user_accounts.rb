# frozen_string_literal: true

class CreateUserAccounts < ActiveRecord::Migration[6.0]
  def change
    create_table :user_accounts do |t|
      t.string :external_uid, null: false
      t.string :email
      t.integer :provider, null: false

      t.references :user, index: true, null: false

      t.timestamps
    end

    add_index :user_accounts, %i[user_id provider], unique: true
    add_index :user_accounts, %i[external_uid provider], unique: true
  end
end
