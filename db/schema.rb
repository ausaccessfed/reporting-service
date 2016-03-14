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

ActiveRecord::Schema.define(version: 20160314020610) do

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

  create_table "automated_report_instances", force: :cascade do |t|
    t.integer  "automated_report_id", limit: 4,   null: false
    t.datetime "range_end",                       null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "identifier",          limit: 255, null: false
  end

  add_index "automated_report_instances", ["automated_report_id"], name: "fk_rails_40d5ad7e3d", using: :btree
  add_index "automated_report_instances", ["identifier"], name: "index_automated_report_instances_on_identifier", unique: true, using: :btree
  add_index "automated_report_instances", ["range_end", "automated_report_id"], name: "automated_report_instances_start_report", unique: true, using: :btree

  create_table "automated_report_subscriptions", force: :cascade do |t|
    t.integer  "automated_report_id", limit: 4,   null: false
    t.integer  "subject_id",          limit: 4,   null: false
    t.string   "identifier",          limit: 255, null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "automated_report_subscriptions", ["automated_report_id"], name: "fk_rails_f6b97923bf", using: :btree
  add_index "automated_report_subscriptions", ["identifier"], name: "index_automated_report_subscriptions_on_identifier", unique: true, using: :btree
  add_index "automated_report_subscriptions", ["subject_id"], name: "fk_rails_59e1f019b3", using: :btree

  create_table "automated_reports", force: :cascade do |t|
    t.string   "report_class",        limit: 255, null: false
    t.string   "interval",            limit: 255, null: false
    t.string   "target",              limit: 255
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.datetime "instances_timestamp"
  end

  create_table "discovery_service_events", force: :cascade do |t|
    t.string   "user_agent",       limit: 4096
    t.string   "ip",               limit: 255,  null: false
    t.string   "group",            limit: 255,  null: false
    t.string   "phase",            limit: 255,  null: false
    t.string   "unique_id",        limit: 255,  null: false
    t.datetime "timestamp",                     null: false
    t.string   "selection_method", limit: 255
    t.string   "return_url",       limit: 255
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "initiating_sp",    limit: 255,  null: false
    t.string   "selected_idp",     limit: 255
  end

  add_index "discovery_service_events", ["phase", "unique_id"], name: "index_discovery_service_events_on_phase_and_unique_id", unique: true, using: :btree
  add_index "discovery_service_events", ["timestamp"], name: "index_discovery_service_events_on_timestamp", using: :btree

  create_table "federated_login_events", force: :cascade do |t|
    t.string   "relying_party",         limit: 255, null: false
    t.string   "asserting_party",       limit: 255, null: false
    t.string   "result",                limit: 255, null: false
    t.string   "hashed_principal_name", limit: 255, null: false
    t.datetime "timestamp",                         null: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "federated_login_events", ["hashed_principal_name"], name: "index_federated_login_events_on_hashed_principal_name", using: :btree

  create_table "identity_provider_saml_attributes", force: :cascade do |t|
    t.integer  "identity_provider_id", limit: 4, null: false
    t.integer  "saml_attribute_id",    limit: 4, null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "identity_provider_saml_attributes", ["identity_provider_id", "saml_attribute_id"], name: "unique_identity_provider_attribute", unique: true, using: :btree
  add_index "identity_provider_saml_attributes", ["saml_attribute_id"], name: "fk_rails_3afed16ec1", using: :btree

  create_table "identity_providers", force: :cascade do |t|
    t.string   "entity_id",       limit: 255, null: false
    t.string   "name",            limit: 255, null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "organization_id", limit: 4,   null: false
  end

  add_index "identity_providers", ["entity_id"], name: "index_identity_providers_on_entity_id", unique: true, using: :btree
  add_index "identity_providers", ["organization_id"], name: "fk_rails_7a44c5f546", using: :btree

  create_table "incoming_f_ticks_events", force: :cascade do |t|
    t.string   "data",       limit: 4096,                 null: false
    t.string   "ip",         limit: 255,                  null: false
    t.boolean  "discarded",               default: false, null: false
    t.datetime "timestamp",                               null: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  add_index "incoming_f_ticks_events", ["discarded"], name: "index_incoming_f_ticks_events_on_discarded", using: :btree

  create_table "organizations", force: :cascade do |t|
    t.string   "identifier", limit: 255, null: false
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "organizations", ["identifier"], name: "index_organizations_on_identifier", unique: true, using: :btree

  create_table "permissions", force: :cascade do |t|
    t.integer  "role_id",    limit: 4,   null: false
    t.string   "value",      limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "permissions", ["role_id", "value"], name: "index_permissions_on_role_id_and_value", unique: true, using: :btree

  create_table "rapid_connect_services", force: :cascade do |t|
    t.string   "identifier",      limit: 255, null: false
    t.string   "name",            limit: 255, null: false
    t.string   "service_type",    limit: 255, null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "organization_id", limit: 4
  end

  add_index "rapid_connect_services", ["identifier"], name: "index_rapid_connect_services_on_identifier", unique: true, using: :btree
  add_index "rapid_connect_services", ["organization_id"], name: "fk_rails_b509da8b0a", using: :btree

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
    t.boolean  "core",                    null: false
  end

  add_index "saml_attributes", ["name"], name: "index_saml_attributes_on_name", unique: true, using: :btree

  create_table "service_provider_saml_attributes", force: :cascade do |t|
    t.integer  "service_provider_id", limit: 4, null: false
    t.integer  "saml_attribute_id",   limit: 4, null: false
    t.boolean  "optional",                      null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "service_provider_saml_attributes", ["saml_attribute_id"], name: "fk_rails_5dcfbc93eb", using: :btree
  add_index "service_provider_saml_attributes", ["service_provider_id", "saml_attribute_id"], name: "unique_service_provider_attribute", unique: true, using: :btree

  create_table "service_providers", force: :cascade do |t|
    t.string   "entity_id",       limit: 255, null: false
    t.string   "name",            limit: 255, null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "organization_id", limit: 4,   null: false
  end

  add_index "service_providers", ["entity_id"], name: "index_service_providers_on_entity_id", unique: true, using: :btree
  add_index "service_providers", ["organization_id"], name: "fk_rails_36567d88d4", using: :btree

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
  add_foreign_key "automated_report_instances", "automated_reports"
  add_foreign_key "automated_report_subscriptions", "automated_reports"
  add_foreign_key "automated_report_subscriptions", "subjects"
  add_foreign_key "identity_provider_saml_attributes", "identity_providers"
  add_foreign_key "identity_provider_saml_attributes", "saml_attributes"
  add_foreign_key "identity_providers", "organizations"
  add_foreign_key "permissions", "roles"
  add_foreign_key "rapid_connect_services", "organizations"
  add_foreign_key "service_provider_saml_attributes", "saml_attributes"
  add_foreign_key "service_provider_saml_attributes", "service_providers"
  add_foreign_key "service_providers", "organizations"
  add_foreign_key "subject_roles", "roles"
  add_foreign_key "subject_roles", "subjects"
end
