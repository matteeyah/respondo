# frozen_string_literal: true

class CreateTickets < ActiveRecord::Migration[6.0]
  def change
    create_table :tickets do |t|
      t.string :external_uid, null: false
      t.text :content, null: false
      t.references :brand, index: true, null: false
      t.references :author, index: true, null: false
      t.references :parent, index: true, null: true
    end
  end
end