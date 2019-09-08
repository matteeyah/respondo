# frozen_string_literal: true

class CreateTickets < ActiveRecord::Migration[6.0]
  def change
    create_table :tickets do |t|
      t.bigint :external_uid, null: false
      t.string :user, null: false
      t.text :content, null: false
      t.references :brand, index: true, null: false
    end
  end
end
