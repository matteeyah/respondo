# frozen_string_literal: true

class CreateInternalTickets < ActiveRecord::Migration[7.0]
  def change
    create_table :internal_tickets do |t|
      t.references :source, index: true, null: false

      t.timestamps
    end
  end
end
