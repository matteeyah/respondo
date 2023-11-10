# frozen_string_literal: true

class CreateMentions < ActiveRecord::Migration[7.0]
  def change
    create_table :mentions do |t|
      t.string :external_uid, null: false
      t.text :content, null: false
      t.integer :status, default: 0, null: false
      t.string :external_link, null: false

      t.references :organization, index: true, null: false
      t.references :author, index: true, null: false
      t.references :creator, index: true, null: true
      t.references :parent, index: true, null: true
      t.references :source, index: true, null: false

      t.timestamps
    end

    add_index :mentions, %i[external_uid source_id], unique: true
  end
end
