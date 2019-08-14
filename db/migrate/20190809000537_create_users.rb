# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :external_uid, null: false
      t.string :name, null: false
      t.string :email, null: false
    end
  end
end
