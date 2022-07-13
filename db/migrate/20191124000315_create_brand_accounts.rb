# frozen_string_literal: true

class CreateBrandAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :brand_accounts do |t|
      t.string :external_uid, null: false
      t.string :email
      t.integer :provider, null: false

      t.string :token
      t.string :secret

      t.references :brand, index: true, null: false

      t.timestamps
    end

    add_index :brand_accounts, %i[brand_id provider], unique: true
    add_index :brand_accounts, %i[external_uid provider], unique: true
  end
end
