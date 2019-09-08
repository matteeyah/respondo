# frozen_string_literal: true

class CreateAuthors < ActiveRecord::Migration[6.0]
  def change
    create_table :authors do |t|
      t.string :external_uid, null: false
      t.string :username, null: false
    end
  end
end
