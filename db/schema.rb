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

ActiveRecord::Schema[8.0].define(version: 2023_11_23_102041) do
  create_table "assignments", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "mention_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["mention_id"], name: "index_assignments_on_mention_id", unique: true
    t.index ["user_id"], name: "index_assignments_on_user_id"
  end

  create_table "authors", force: :cascade do |t|
    t.string "external_uid", null: false
    t.string "username", null: false
    t.string "external_link", null: false
    t.integer "provider", null: false
    t.integer "organization_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_uid", "provider", "organization_id"], name: "index_authors_on_external_uid_and_provider_and_organization_id", unique: true
    t.index ["organization_id"], name: "index_authors_on_organization_id"
  end

  create_table "internal_notes", force: :cascade do |t|
    t.text "content", null: false
    t.integer "creator_id", null: false
    t.integer "mention_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_internal_notes_on_creator_id"
    t.index ["mention_id"], name: "index_internal_notes_on_mention_id"
  end

  create_table "mention_tags", force: :cascade do |t|
    t.integer "mention_id", null: false
    t.integer "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["mention_id", "tag_id"], name: "index_mention_tags_on_mention_id_and_tag_id", unique: true
    t.index ["mention_id"], name: "index_mention_tags_on_mention_id"
    t.index ["tag_id"], name: "index_mention_tags_on_tag_id"
  end

  create_table "mentions", force: :cascade do |t|
    t.string "external_uid", null: false
    t.text "content", null: false
    t.integer "status", default: 0, null: false
    t.string "external_link", null: false
    t.integer "organization_id", null: false
    t.integer "author_id", null: false
    t.integer "creator_id"
    t.integer "parent_id"
    t.integer "source_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_mentions_on_author_id"
    t.index ["creator_id"], name: "index_mentions_on_creator_id"
    t.index ["external_uid", "source_id"], name: "index_mentions_on_external_uid_and_source_id", unique: true
    t.index ["organization_id"], name: "index_mentions_on_organization_id"
    t.index ["parent_id"], name: "index_mentions_on_parent_id"
    t.index ["source_id"], name: "index_mentions_on_source_id"
  end

  create_table "organization_accounts", force: :cascade do |t|
    t.string "external_uid", null: false
    t.string "email"
    t.string "screen_name", null: false
    t.integer "provider", null: false
    t.string "token"
    t.string "secret"
    t.integer "organization_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_uid", "provider"], name: "index_organization_accounts_on_external_uid_and_provider", unique: true
    t.index ["organization_id"], name: "index_organization_accounts_on_organization_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "screen_name", null: false
    t.string "domain"
    t.text "ai_guidelines"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domain"], name: "index_organizations_on_domain", unique: true
  end

  create_table "products", force: :cascade do |t|
    t.string "name", null: false
    t.text "description", null: false
    t.integer "organization_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_products_on_organization_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "user_accounts", force: :cascade do |t|
    t.string "external_uid", null: false
    t.string "email"
    t.integer "provider", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "provider"], name: "index_user_accounts_on_user_id_and_provider", unique: true
    t.index ["user_id"], name: "index_user_accounts_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "organization_id"
    t.index ["organization_id"], name: "index_users_on_organization_id"
  end

  add_foreign_key "authors", "organizations"
  add_foreign_key "mention_tags", "mentions"
  add_foreign_key "mention_tags", "tags"
end
