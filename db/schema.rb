# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150819035849) do

  create_table "api_subjects", force: :cascade do |t|
    t.string   "x509_cn",      limit: 255,                null: false
    t.string   "contact_name", limit: 255,                null: false
    t.string   "contact_mail", limit: 255,                null: false
    t.string   "description",  limit: 255,                null: false
    t.boolean  "enabled",                  default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "api_subjects", ["x509_cn"], name: "index_api_subjects_on_x509_cn", unique: true, using: :btree

  create_table "permissions", force: :cascade do |t|
    t.integer  "role_id",    limit: 4,   null: false
    t.string   "value",      limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "permissions", ["role_id", "value"], name: "index_permissions_on_role_id_and_value", unique: true, using: :btree

  create_table "roles", force: :cascade do |t|
    t.string   "name",        limit: 255, null: false
    t.string   "entitlement", limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["entitlement"], name: "index_roles_on_entitlement", unique: true, using: :btree

  create_table "subject_roles", force: :cascade do |t|
    t.integer  "subject_id", limit: 4, null: false
    t.integer  "role_id",    limit: 4, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "subject_roles", ["subject_id", "role_id"], name: "index_subject_roles_on_subject_id_and_role_id", unique: true, using: :btree

  create_table "subjects", force: :cascade do |t|
    t.string   "targeted_id",  limit: 255,                null: false
    t.string   "shared_token", limit: 255,                null: false
    t.string   "name",         limit: 255,                null: false
    t.string   "mail",         limit: 255,                null: false
    t.boolean  "enabled",                  default: true, null: false
    t.boolean  "complete",                 default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "subjects", ["shared_token"], name: "index_subjects_on_shared_token", unique: true, using: :btree
  add_index "subjects", ["targeted_id"], name: "index_subjects_on_targeted_id", unique: true, using: :btree

end
