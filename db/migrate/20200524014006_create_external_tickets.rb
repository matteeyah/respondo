# frozen_string_literal: true

class CreateExternalTickets < ActiveRecord::Migration[6.0]
  def change
    create_table :external_tickets do |t|
      t.string :response_url, null: false
      t.string :custom_provider, null: true, default: nil

      t.timestamps
    end
  end
end
