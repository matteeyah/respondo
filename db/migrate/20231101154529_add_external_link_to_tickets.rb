# frozen_string_literal: true

class AddExternalLinkToTickets < ActiveRecord::Migration[7.1]
  def change
    add_column :tickets, :external_link, :string, null: false, default: 'https://respondohub.com'
  end
end
