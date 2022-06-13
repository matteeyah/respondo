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

ActiveRecord::Schema[6.1].define(version: 2020_05_24_021243) do

  create_table "authors", force: :cascade do |t|
    t.string "external_uid", null: false
    t.integer "provider", null: false
    t.string "username", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["external_uid", "provider"], name: "index_authors_on_external_uid_and_provider", unique: true
  end

  create_table "brand_accounts", force: :cascade do |t|
    t.string "external_uid", null: false
    t.string "email"
    t.integer "provider", null: false
    t.string "encrypted_token"
    t.string "encrypted_token_iv"
    t.string "encrypted_secret"
    t.string "encrypted_secret_iv"
    t.integer "brand_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["brand_id", "provider"], name: "index_brand_accounts_on_brand_id_and_provider", unique: true
    t.index ["brand_id"], name: "index_brand_accounts_on_brand_id"
    t.index ["encrypted_secret_iv"], name: "index_brand_accounts_on_encrypted_secret_iv", unique: true
    t.index ["encrypted_token_iv"], name: "index_brand_accounts_on_encrypted_token_iv", unique: true
    t.index ["external_uid", "provider"], name: "index_brand_accounts_on_external_uid_and_provider", unique: true
  end

  create_table "brands", force: :cascade do |t|
    t.string "screen_name", null: false
    t.string "domain"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "external_tickets", force: :cascade do |t|
    t.string "response_url", null: false
    t.string "custom_provider"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "flipper_features", force: :cascade do |t|
    t.string "key", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["key"], name: "index_flipper_features_on_key", unique: true
  end

  create_table "flipper_gates", force: :cascade do |t|
    t.string "feature_key", null: false
    t.string "key", null: false
    t.string "value"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["feature_key", "key", "value"], name: "index_flipper_gates_on_feature_key_and_key_and_value", unique: true
  end

  create_table "internal_notes", force: :cascade do |t|
    t.text "content", null: false
    t.integer "creator_id", null: false
    t.integer "ticket_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["creator_id"], name: "index_internal_notes_on_creator_id"
    t.index ["ticket_id"], name: "index_internal_notes_on_ticket_id"
  end

  create_table "internal_tickets", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "personal_access_tokens", force: :cascade do |t|
    t.string "name", null: false
    t.string "token_digest", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_personal_access_tokens_on_name", unique: true
    t.index ["user_id"], name: "index_personal_access_tokens_on_user_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.string "external_uid", null: false
    t.integer "status", null: false
    t.string "email", null: false
    t.string "cancel_url", null: false
    t.string "update_url", null: false
    t.integer "brand_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["brand_id"], name: "index_subscriptions_on_brand_id"
  end

  create_table "tickets", force: :cascade do |t|
    t.string "external_uid", null: false
    t.text "content", null: false
    t.integer "status", null: false
    t.integer "provider", null: false
    t.string "ticketable_type", null: false
    t.integer "ticketable_id", null: false
    t.integer "brand_id", null: false
    t.integer "author_id", null: false
    t.integer "creator_id"
    t.integer "parent_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["author_id"], name: "index_tickets_on_author_id"
    t.index ["brand_id"], name: "index_tickets_on_brand_id"
    t.index ["creator_id"], name: "index_tickets_on_creator_id"
    t.index ["external_uid", "ticketable_type", "brand_id"], name: "index_tickets_on_external_uid_and_ticketable_type_and_brand_id", unique: true
    t.index ["parent_id"], name: "index_tickets_on_parent_id"
  end

  create_table "user_accounts", force: :cascade do |t|
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
    t.index ["encrypted_secret_iv"], name: "index_user_accounts_on_encrypted_secret_iv", unique: true
    t.index ["encrypted_token_iv"], name: "index_user_accounts_on_encrypted_token_iv", unique: true
    t.index ["external_uid", "provider"], name: "index_user_accounts_on_external_uid_and_provider", unique: true
    t.index ["user_id", "provider"], name: "index_user_accounts_on_user_id_and_provider", unique: true
    t.index ["user_id"], name: "index_user_accounts_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "brand_id"
    t.index ["brand_id"], name: "index_users_on_brand_id"
  end

  add_foreign_key "internal_notes", "users", column: "creator_id"
  add_foreign_key "tickets", "users", column: "creator_id"
end
