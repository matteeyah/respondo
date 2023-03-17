# frozen_string_literal: true

class CreateEmailTickets < ActiveRecord::Migration[7.0]
  def change
    create_table :email_tickets do |t|
      t.string :reply_to, null: false
      t.string :subject, null: false

      t.timestamps
    end
  end
end
