# frozen_string_literal: true

class AddTokenToBrands < ActiveRecord::Migration[6.0]
  def change
    add_column :brands, :token, :string
    add_column :brands, :secret, :string
  end
end
