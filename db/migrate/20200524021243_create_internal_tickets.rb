# frozen_string_literal: true

class CreateInternalTickets < ActiveRecord::Migration[6.0]
  def change
    create_table :internal_tickets, &:timestamps
  end
end
