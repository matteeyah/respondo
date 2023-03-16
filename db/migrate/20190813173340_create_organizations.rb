# frozen_string_literal: true

class CreateOrganizations < ActiveRecord::Migration[7.0]
  def change
    create_table :organizations do |t|
      t.string :screen_name, null: false
      t.string :domain, null: true, index: { unique: true }

      t.timestamps
    end

    add_reference :users, :organization, index: true, null: true
  end
end
