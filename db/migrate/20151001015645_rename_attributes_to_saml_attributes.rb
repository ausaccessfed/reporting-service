# frozen_string_literal: true

class RenameAttributesToSAMLAttributes < ActiveRecord::Migration[4.2]
  def change
    remove_foreign_key :service_provider_attributes, :attributes
    remove_foreign_key :identity_provider_attributes, :attributes

    rename_table :attributes, :saml_attributes

    rename_column :identity_provider_attributes, :attribute_id, :saml_attribute_id

    rename_table :identity_provider_attributes, :identity_provider_saml_attributes

    rename_column :service_provider_attributes, :attribute_id, :saml_attribute_id

    rename_table :service_provider_attributes, :service_provider_saml_attributes

    add_foreign_key :service_provider_saml_attributes, :saml_attributes
    add_foreign_key :identity_provider_saml_attributes, :saml_attributes
  end
end
