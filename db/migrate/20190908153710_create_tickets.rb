# frozen_string_literal: true

class CreateTickets < ActiveRecord::Migration[6.0]
  def change
    create_table :tickets do |t|
      t.string :external_uid, null: false
      t.text :content, null: false
      t.integer :status, null: false
      t.integer :provider, null: false

      t.string :ticketable_type, null: false
      t.integer :ticketable_id, null: false

      t.references :brand, index: true, null: false
      t.references :author, index: true, null: false
      t.references :creator, index: true, null: true, foreign_key: { to_table: :users }
      t.references :parent, index: true, null: true

      t.timestamps
    end

    add_index :tickets, %i[external_uid ticketable_type brand_id], unique: true
  end
end
