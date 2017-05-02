# frozen_string_literal: true

class AddUniqueKeysToFederationData < ActiveRecord::Migration
  def change
    add_index :identity_providers, :entity_id, unique: true
    add_index :service_providers, :entity_id, unique: true
    add_index :organizations, :identifier, unique: true
    add_index :rapid_connect_services, :identifier, unique: true
    add_index :saml_attributes, :name, unique: true
  end
end
