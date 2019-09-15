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

ActiveRecord::Schema.define(version: 2019_09_12_173327) do

  create_table "accounts", force: :cascade do |t|
    t.string "external_uid", null: false
    t.string "email"
    t.integer "provider", null: false
    t.string "encrypted_token"
    t.string "encrypted_token_iv"
    t.string "encrypted_secret"
    t.string "encrypted_secret_iv"
    t.integer "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["encrypted_secret_iv"], name: "index_accounts_on_encrypted_secret_iv", unique: true
    t.index ["encrypted_token_iv"], name: "index_accounts_on_encrypted_token_iv", unique: true
    t.index ["external_uid", "provider"], name: "index_accounts_on_external_uid_and_provider", unique: true
    t.index ["user_id", "provider"], name: "index_accounts_on_user_id_and_provider", unique: true
    t.index ["user_id"], name: "index_accounts_on_user_id"
  end

  create_table "authors", force: :cascade do |t|
    t.string "external_uid", null: false
    t.integer "provider", null: false
    t.string "username", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["external_uid", "provider"], name: "index_authors_on_external_uid_and_provider", unique: true
  end

  create_table "brands", force: :cascade do |t|
    t.string "external_uid", null: false
    t.string "screen_name", null: false
    t.string "encrypted_token"
    t.string "encrypted_token_iv"
    t.string "encrypted_secret"
    t.string "encrypted_secret_iv"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["encrypted_secret_iv"], name: "index_brands_on_encrypted_secret_iv", unique: true
    t.index ["encrypted_token_iv"], name: "index_brands_on_encrypted_token_iv", unique: true
    t.index ["external_uid"], name: "index_brands_on_external_uid", unique: true
  end

  create_table "tickets", force: :cascade do |t|
    t.string "external_uid", null: false
    t.integer "provider", null: false
    t.text "content", null: false
    t.integer "status", default: 0, null: false
    t.integer "brand_id", null: false
    t.integer "author_id", null: false
    t.integer "parent_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["author_id"], name: "index_tickets_on_author_id"
    t.index ["brand_id"], name: "index_tickets_on_brand_id"
    t.index ["external_uid", "provider", "brand_id"], name: "index_tickets_on_external_uid_and_provider_and_brand_id", unique: true
    t.index ["parent_id"], name: "index_tickets_on_parent_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "brand_id"
    t.index ["brand_id"], name: "index_users_on_brand_id"
  end

end
