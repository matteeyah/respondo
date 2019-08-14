# frozen_string_literal: true

class CreateBrand < ActiveRecord::Migration[6.0]
  def change
    create_table :brands do |t|
      t.string :external_uid, null: false
      t.string :nickname, null: false
    end

    add_reference :users, :brand, index: true
  end
end
