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

ActiveRecord::Schema.define(version: 20151001015645) do

  create_table "activations", force: :cascade do |t|
    t.integer  "federation_object_id",   limit: 4,   null: false
    t.string   "federation_object_type", limit: 255, null: false
    t.datetime "activated_at",                       null: false
    t.datetime "deactivated_at"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  create_table "api_subject_roles", force: :cascade do |t|
    t.integer  "api_subject_id", limit: 4, null: false
    t.integer  "role_id",        limit: 4, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "api_subject_roles", ["api_subject_id", "role_id"], name: "index_api_subject_roles_on_api_subject_id_and_role_id", unique: true, using: :btree
  add_index "api_subject_roles", ["role_id"], name: "fk_rails_3c99dcce56", using: :btree

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

  create_table "identity_provider_saml_attributes", force: :cascade do |t|
    t.integer  "identity_provider_id", limit: 4, null: false
    t.integer  "saml_attribute_id",    limit: 4, null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "identity_provider_saml_attributes", ["identity_provider_id", "saml_attribute_id"], name: "unique_identity_provider_attribute", unique: true, using: :btree
  add_index "identity_provider_saml_attributes", ["saml_attribute_id"], name: "fk_rails_94f14b5952", using: :btree

  create_table "identity_providers", force: :cascade do |t|
    t.string   "entity_id",  limit: 255, null: false
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "organizations", force: :cascade do |t|
    t.string   "identifier", limit: 255, null: false
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "permissions", force: :cascade do |t|
    t.integer  "role_id",    limit: 4,   null: false
    t.string   "value",      limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "permissions", ["role_id", "value"], name: "index_permissions_on_role_id_and_value", unique: true, using: :btree

  create_table "rapid_connect_services", force: :cascade do |t|
    t.string   "identifier", limit: 255, null: false
    t.string   "name",       limit: 255, null: false
    t.string   "type",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "roles", force: :cascade do |t|
    t.string   "name",        limit: 255, null: false
    t.string   "entitlement", limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["entitlement"], name: "index_roles_on_entitlement", unique: true, using: :btree

  create_table "saml_attributes", force: :cascade do |t|
    t.string   "name",        limit: 255, null: false
    t.string   "description", limit: 255, null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "service_provider_saml_attributes", force: :cascade do |t|
    t.integer  "service_provider_id", limit: 4, null: false
    t.integer  "saml_attribute_id",   limit: 4, null: false
    t.boolean  "optional",                      null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "service_provider_saml_attributes", ["saml_attribute_id"], name: "fk_rails_de72af15ed", using: :btree
  add_index "service_provider_saml_attributes", ["service_provider_id", "saml_attribute_id"], name: "unique_identity_provider_attribute", unique: true, using: :btree

  create_table "service_providers", force: :cascade do |t|
    t.string   "entity_id",  limit: 255, null: false
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "subject_roles", force: :cascade do |t|
    t.integer  "subject_id", limit: 4, null: false
    t.integer  "role_id",    limit: 4, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "subject_roles", ["role_id"], name: "fk_rails_775c958b0f", using: :btree
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

  add_foreign_key "api_subject_roles", "api_subjects"
  add_foreign_key "api_subject_roles", "roles"
  add_foreign_key "identity_provider_saml_attributes", "identity_providers"
  add_foreign_key "identity_provider_saml_attributes", "saml_attributes"
  add_foreign_key "permissions", "roles"
  add_foreign_key "service_provider_saml_attributes", "saml_attributes"
  add_foreign_key "service_provider_saml_attributes", "service_providers"
  add_foreign_key "subject_roles", "roles"
  add_foreign_key "subject_roles", "subjects"
end
