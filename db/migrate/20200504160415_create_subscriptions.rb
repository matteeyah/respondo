# frozen_string_literal: true

class CreateSubscriptions < ActiveRecord::Migration[7.0]
  def change
    create_table :subscriptions do |t|
      t.string :external_uid, null: false
      t.integer :status, null: false
      t.string :email, null: false
      t.string :cancel_url, null: false
      t.string :update_url, null: false
      t.references :brand, index: true, unique: true, null: false

      t.timestamps
    end
  end
end
