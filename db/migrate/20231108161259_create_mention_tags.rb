# frozen_string_literal: true

class CreateMentionTags < ActiveRecord::Migration[7.1]
  def change
    create_table :mention_tags do |t|
      t.references :mention, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps
    end

    add_index :mention_tags, %i[mention_id tag_id], unique: true
  end
end
