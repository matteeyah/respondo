# frozen_string_literal: true

class RemoveResponseUrlFromExternalTickets < ActiveRecord::Migration[7.1]
  def change
    remove_column :external_tickets, :response_url, :string
  end
end
