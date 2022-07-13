# frozen_string_literal: true

class CreatePersonalAccessTokens < ActiveRecord::Migration[7.0]
  def change
    create_table :personal_access_tokens do |t|
      t.string :name, index: { unique: true }, null: false
      t.string :token_digest, null: false

      t.references :user, index: true, null: false

      t.timestamps
    end
  end
end
