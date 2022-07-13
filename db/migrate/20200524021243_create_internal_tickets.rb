# frozen_string_literal: true

class CreateInternalTickets < ActiveRecord::Migration[7.0]
  def change
    create_table :internal_tickets, &:timestamps
  end
end
