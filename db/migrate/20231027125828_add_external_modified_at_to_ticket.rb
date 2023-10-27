class AddExternalModifiedAtToTicket < ActiveRecord::Migration[7.0]
  def change
    add_column :tickets, :external_modified_at, :bigint
  end
end
