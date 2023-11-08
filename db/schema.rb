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

ActiveRecord::Schema[7.1].define(version: 2023_11_08_161259) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "assignments", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "ticket_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ticket_id"], name: "index_assignments_on_ticket_id", unique: true
    t.index ["user_id"], name: "index_assignments_on_user_id"
  end

  create_table "authors", force: :cascade do |t|
    t.string "external_uid", null: false
    t.integer "provider", null: false
    t.string "username", null: false
    t.string "external_link", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_uid", "provider"], name: "index_authors_on_external_uid_and_provider", unique: true
  end

  create_table "internal_notes", force: :cascade do |t|
    t.text "content", null: false
    t.bigint "creator_id", null: false
    t.bigint "ticket_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_internal_notes_on_creator_id"
    t.index ["ticket_id"], name: "index_internal_notes_on_ticket_id"
  end

  create_table "organization_accounts", force: :cascade do |t|
    t.string "external_uid", null: false
    t.string "email"
    t.string "screen_name", null: false
    t.integer "provider", null: false
    t.string "token"
    t.string "secret"
    t.bigint "organization_id", null: false
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

  create_table "tags", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "ticket_tags", force: :cascade do |t|
    t.bigint "ticket_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tag_id"], name: "index_ticket_tags_on_tag_id"
    t.index ["ticket_id", "tag_id"], name: "index_ticket_tags_on_ticket_id_and_tag_id", unique: true
    t.index ["ticket_id"], name: "index_ticket_tags_on_ticket_id"
  end

  create_table "tickets", force: :cascade do |t|
    t.string "external_uid", null: false
    t.text "content", null: false
    t.integer "status", default: 0, null: false
    t.string "external_link", null: false
    t.bigint "organization_id", null: false
    t.bigint "author_id", null: false
    t.bigint "creator_id"
    t.bigint "parent_id"
    t.bigint "source_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_tickets_on_author_id"
    t.index ["creator_id"], name: "index_tickets_on_creator_id"
    t.index ["external_uid", "source_id"], name: "index_tickets_on_external_uid_and_source_id", unique: true
    t.index ["organization_id"], name: "index_tickets_on_organization_id"
    t.index ["parent_id"], name: "index_tickets_on_parent_id"
    t.index ["source_id"], name: "index_tickets_on_source_id"
  end

  create_table "user_accounts", force: :cascade do |t|
    t.string "external_uid", null: false
    t.string "email"
    t.integer "provider", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "provider"], name: "index_user_accounts_on_user_id_and_provider", unique: true
    t.index ["user_id"], name: "index_user_accounts_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "organization_id"
    t.index ["organization_id"], name: "index_users_on_organization_id"
  end

  add_foreign_key "ticket_tags", "tags"
  add_foreign_key "ticket_tags", "tickets"
end
