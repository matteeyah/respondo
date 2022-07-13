# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2022_07_13_110717) do
  create_table "authors", force: :cascade do |t|
    t.string "external_uid", null: false
    t.integer "provider", null: false
    t.string "username", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_uid", "provider"], name: "index_authors_on_external_uid_and_provider", unique: true
  end

  create_table "brand_accounts", force: :cascade do |t|
    t.string "external_uid", null: false
    t.string "email"
    t.integer "provider", null: false
    t.string "token"
    t.string "secret"
    t.integer "brand_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["brand_id", "provider"], name: "index_brand_accounts_on_brand_id_and_provider", unique: true
    t.index ["brand_id"], name: "index_brand_accounts_on_brand_id"
    t.index ["external_uid", "provider"], name: "index_brand_accounts_on_external_uid_and_provider", unique: true
  end

  create_table "brands", force: :cascade do |t|
    t.string "screen_name", null: false
    t.string "domain"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "external_tickets", force: :cascade do |t|
    t.string "response_url", null: false
    t.string "custom_provider"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "flipper_features", force: :cascade do |t|
    t.string "key", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_flipper_features_on_key", unique: true
  end

  create_table "flipper_gates", force: :cascade do |t|
    t.string "feature_key", null: false
    t.string "key", null: false
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["feature_key", "key", "value"], name: "index_flipper_gates_on_feature_key_and_key_and_value", unique: true
  end

  create_table "internal_notes", force: :cascade do |t|
    t.text "content", null: false
    t.integer "creator_id", null: false
    t.integer "ticket_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_internal_notes_on_creator_id"
    t.index ["ticket_id"], name: "index_internal_notes_on_ticket_id"
  end

  create_table "internal_tickets", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "personal_access_tokens", force: :cascade do |t|
    t.string "name", null: false
    t.string "token_digest", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["brand_id"], name: "index_subscriptions_on_brand_id"
  end

  create_table "taggings", force: :cascade do |t|
    t.integer "tag_id"
    t.string "taggable_type"
    t.integer "taggable_id"
    t.string "tagger_type"
    t.integer "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at", precision: nil
    t.string "tenant", limit: 128
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "taggings_taggable_context_idx"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type", "taggable_id"], name: "index_taggings_on_taggable_type_and_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
    t.index ["tagger_type", "tagger_id"], name: "index_taggings_on_tagger_type_and_tagger_id"
    t.index ["tenant"], name: "index_taggings_on_tenant"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_uid", "provider"], name: "index_user_accounts_on_external_uid_and_provider", unique: true
    t.index ["user_id", "provider"], name: "index_user_accounts_on_user_id_and_provider", unique: true
    t.index ["user_id"], name: "index_user_accounts_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "brand_id"
    t.index ["brand_id"], name: "index_users_on_brand_id"
  end

  add_foreign_key "internal_notes", "users", column: "creator_id"
  add_foreign_key "taggings", "tags"
  add_foreign_key "tickets", "users", column: "creator_id"
end
