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

ActiveRecord::Schema.define(version: 2020_02_09_214427) do

  create_table "activations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.string "federation_object_type", null: false
    t.integer "federation_object_id", null: false
    t.datetime "activated_at", null: false
    t.datetime "deactivated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "api_subject_roles", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.integer "api_subject_id", null: false
    t.integer "role_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["api_subject_id", "role_id"], name: "index_api_subject_roles_on_api_subject_id_and_role_id", unique: true
    t.index ["role_id"], name: "fk_rails_3c99dcce56"
  end

  create_table "api_subjects", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.string "x509_cn", null: false
    t.string "contact_name", null: false
    t.string "contact_mail", null: false
    t.string "description", null: false
    t.boolean "enabled", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["x509_cn"], name: "index_api_subjects_on_x509_cn", unique: true
  end

  create_table "automated_report_instances", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.integer "automated_report_id", null: false
    t.datetime "range_end", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "identifier", null: false
    t.index ["automated_report_id"], name: "fk_rails_40d5ad7e3d"
    t.index ["identifier"], name: "index_automated_report_instances_on_identifier", unique: true
    t.index ["range_end", "automated_report_id"], name: "automated_report_instances_start_report", unique: true
  end

  create_table "automated_report_subscriptions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.integer "automated_report_id", null: false
    t.integer "subject_id", null: false
    t.string "identifier", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["automated_report_id"], name: "fk_rails_f6b97923bf"
    t.index ["identifier"], name: "index_automated_report_subscriptions_on_identifier", unique: true
    t.index ["subject_id"], name: "fk_rails_59e1f019b3"
  end

  create_table "automated_reports", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.string "report_class", null: false
    t.string "interval", null: false
    t.string "target"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "instances_timestamp"
    t.string "source"
  end

  create_table "discovery_service_events", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.string "user_agent", limit: 4096
    t.string "ip", null: false
    t.string "group", null: false
    t.string "phase", null: false
    t.string "unique_id", null: false
    t.datetime "timestamp", null: false
    t.string "selection_method"
    t.string "return_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "initiating_sp", null: false
    t.string "selected_idp"
    t.index ["phase", "timestamp"], name: "index_discovery_service_events_on_phase_and_timestamp"
    t.index ["unique_id", "phase"], name: "index_discovery_service_events_on_unique_id_and_phase", unique: true
  end

  create_table "federated_login_events", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.string "relying_party", null: false
    t.string "asserting_party", null: false
    t.string "result", null: false
    t.string "hashed_principal_name", null: false
    t.datetime "timestamp", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["hashed_principal_name"], name: "index_federated_login_events_on_hashed_principal_name"
    t.index ["result", "timestamp"], name: "index_federated_login_events_on_result_and_timestamp"
  end

  create_table "identity_provider_saml_attributes", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.integer "identity_provider_id", null: false
    t.integer "saml_attribute_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["identity_provider_id", "saml_attribute_id"], name: "unique_identity_provider_attribute", unique: true
    t.index ["saml_attribute_id"], name: "fk_rails_3afed16ec1"
  end

  create_table "identity_providers", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.string "entity_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "organization_id", null: false
    t.index ["entity_id"], name: "index_identity_providers_on_entity_id", unique: true
    t.index ["organization_id"], name: "fk_rails_7a44c5f546"
  end

  create_table "incoming_f_ticks_events", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.string "data", limit: 4096, null: false
    t.string "ip", null: false
    t.boolean "discarded", default: false, null: false
    t.datetime "timestamp", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded"], name: "index_incoming_f_ticks_events_on_discarded"
  end

  create_table "organizations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.string "identifier", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["identifier"], name: "index_organizations_on_identifier", unique: true
  end

  create_table "permissions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.integer "role_id", null: false
    t.string "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["role_id", "value"], name: "index_permissions_on_role_id_and_value", unique: true
  end

  create_table "rapid_connect_services", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.string "identifier", null: false
    t.string "name", null: false
    t.string "service_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "organization_id"
    t.index ["identifier"], name: "index_rapid_connect_services_on_identifier", unique: true
    t.index ["organization_id"], name: "fk_rails_b509da8b0a"
  end

  create_table "roles", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.string "name", null: false
    t.string "entitlement", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["entitlement"], name: "index_roles_on_entitlement", unique: true
  end

  create_table "saml_attributes", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.string "name", null: false
    t.string "description", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "core", null: false
    t.index ["name"], name: "index_saml_attributes_on_name", unique: true
  end

  create_table "service_provider_saml_attributes", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.integer "service_provider_id", null: false
    t.integer "saml_attribute_id", null: false
    t.boolean "optional", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["saml_attribute_id"], name: "fk_rails_5dcfbc93eb"
    t.index ["service_provider_id", "saml_attribute_id"], name: "unique_service_provider_attribute", unique: true
  end

  create_table "service_providers", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.string "entity_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "organization_id", null: false
    t.index ["entity_id"], name: "index_service_providers_on_entity_id", unique: true
    t.index ["organization_id"], name: "fk_rails_36567d88d4"
  end

  create_table "subject_roles", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.integer "subject_id", null: false
    t.integer "role_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["role_id"], name: "fk_rails_775c958b0f"
    t.index ["subject_id", "role_id"], name: "index_subject_roles_on_subject_id_and_role_id", unique: true
  end

  create_table "subjects", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.string "targeted_id", null: false
    t.string "shared_token", null: false
    t.string "name", null: false
    t.string "mail", null: false
    t.boolean "enabled", default: true, null: false
    t.boolean "complete", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["shared_token"], name: "index_subjects_on_shared_token", unique: true
    t.index ["targeted_id"], name: "index_subjects_on_targeted_id", unique: true
  end

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
