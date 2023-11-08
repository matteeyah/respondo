# frozen_string_literal: true

class CreateTicketTags < ActiveRecord::Migration[7.1]
  def change
    create_table :ticket_tags do |t|
      t.references :ticket, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps
    end

    add_index :ticket_tags, %i[ticket_id tag_id], unique: true
  end
end
