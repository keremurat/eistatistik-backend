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

ActiveRecord::Schema[8.1].define(version: 2026_11_04_140000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "legal_acceptances", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "document_key", null: false
    t.string "document_version", null: false
    t.datetime "accepted_at", null: false
    t.inet "ip_address"
    t.string "user_agent", limit: 512
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "document_key", "document_version"], name: "index_legal_acceptances_on_user_document_version", unique: true
    t.index ["user_id"], name: "index_legal_acceptances_on_user_id"
    t.check_constraint "document_key::text = ANY (ARRAY['membership_terms'::character varying, 'kvkk_notice'::character varying]::text[])", name: "legal_acceptances_document_key_check"
  end

  create_table "permissions", force: :cascade do |t|
    t.string "key", null: false
    t.string "label", null: false
    t.string "category", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_permissions_on_key", unique: true
  end

  create_table "profiles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_profiles_on_user_id", unique: true
  end

  create_table "role_permissions", force: :cascade do |t|
    t.bigint "role_id", null: false
    t.bigint "permission_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["permission_id"], name: "index_role_permissions_on_permission_id"
    t.index ["role_id", "permission_id"], name: "index_role_permissions_on_role_id_and_permission_id", unique: true
    t.index ["role_id"], name: "index_role_permissions_on_role_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "key", null: false
    t.string "name", null: false
    t.text "description"
    t.boolean "assignable", default: false, null: false
    t.boolean "system_role", default: false, null: false
    t.string "home_path", default: "/admin", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_roles_on_key", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role", default: "musteri", null: false
    t.index "lower((email)::text)", name: "index_users_on_lower_email", unique: true
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  add_foreign_key "legal_acceptances", "users", on_delete: :cascade
  add_foreign_key "profiles", "users", on_delete: :cascade
  add_foreign_key "role_permissions", "permissions"
  add_foreign_key "role_permissions", "roles"
end
