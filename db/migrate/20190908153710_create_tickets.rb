# frozen_string_literal: true

class CreateTickets < ActiveRecord::Migration[7.0]
  def change
    create_table :tickets do |t|
      t.string :external_uid, null: false
      t.text :content, null: false
      t.integer :status, default: 0, null: false

      t.string :ticketable_type, null: false
      t.integer :ticketable_id, null: false

      t.references :organization, index: true, null: false
      t.references :author, index: true, null: false
      t.references :creator, index: true, null: true
      t.references :parent, index: true, null: true

      t.timestamps
    end

    add_index :tickets, %i[external_uid ticketable_type organization_id],
              unique: true, name: 'index_tickets_on_uid_and_ticketable_type_and_organization'
  end
end
