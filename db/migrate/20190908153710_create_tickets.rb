# frozen_string_literal: true

class CreateTickets < ActiveRecord::Migration[6.0]
  def change
    create_table :tickets do |t|
      t.string :external_uid, null: false
      t.integer :provider, null: false
      t.text :content, null: false
      t.integer :status, null: false, default: 0

      t.string :response_url, null: true, default: nil
      t.string :custom_provider, null: true, default: nil

      t.references :brand, index: true, null: false
      t.references :author, index: true, null: false
      t.references :user, index: true, null: true
      t.references :parent, index: true, null: true

      t.timestamps
    end

    add_index :tickets, %i[external_uid provider brand_id], unique: true
  end
end
