# frozen_string_literal: true

class AddExternalLinkToAuthors < ActiveRecord::Migration[7.1]
  def change
    add_column :authors, :external_link, :string
  end
end
