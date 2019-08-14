# frozen_string_literal: true

class AddTokenToBrands < ActiveRecord::Migration[6.0]
  def change
    add_column :brands, :encrypted_token, :string
    add_column :brands, :encrypted_token_iv, :string
    add_column :brands, :encrypted_secret, :string
    add_column :brands, :encrypted_secret_iv, :string

    add_index :brands, :encrypted_token_iv, unique: true
    add_index :brands, :encrypted_secret_iv, unique: true
  end
end
