# frozen_string_literal: true

class CreateEmailTickets < ActiveRecord::Migration[7.0]
  def change
    create_table :email_tickets, &:timestamps
  end
end
