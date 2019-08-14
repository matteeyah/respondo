# frozen_string_literal: true

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20_190_814_144_724) do
  create_table 'brands', force: :cascade do |t|
    t.string 'external_uid'
    t.string 'nickname'
    t.string 'encrypted_token'
    t.string 'encrypted_token_iv'
    t.string 'encrypted_secret'
    t.string 'encrypted_secret_iv'
    t.index ['encrypted_secret_iv'], name: 'index_brands_on_encrypted_secret_iv', unique: true
    t.index ['encrypted_token_iv'], name: 'index_brands_on_encrypted_token_iv', unique: true
  end

  create_table 'users', force: :cascade do |t|
    t.string 'external_uid'
    t.string 'name'
    t.string 'email'
    t.integer 'brand_id'
    t.index ['brand_id'], name: 'index_users_on_brand_id'
  end
end
