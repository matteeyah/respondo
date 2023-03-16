# frozen_string_literal: true

class CreateOrganizationAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :organization_accounts do |t|
      t.string :external_uid, null: false
      t.string :email
      t.string :screen_name, null: false
      t.integer :provider, null: false

      t.string :token
      t.string :secret

      t.references :organization, index: true, null: false

      t.timestamps
    end

    add_index :organization_accounts, %i[external_uid provider], unique: true
  end
end
