# frozen_string_literal: true

class CreateBrand < ActiveRecord::Migration[6.0]
  def change
    create_table :brands do |t|
      t.string :screen_name, null: false

      t.timestamps
    end

    add_reference :users, :brand, index: true, null: true
  end
end
