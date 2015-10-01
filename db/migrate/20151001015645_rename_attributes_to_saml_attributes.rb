class RenameAttributesToSAMLAttributes < ActiveRecord::Migration
  def change
    rename_table :attributes, :saml_attributes

    rename_column :identity_provider_attributes,
                  :attribute_id, :saml_attribute_id

    rename_table :identity_provider_attributes,
                 :identity_provider_saml_attributes

    rename_column :service_provider_attributes,
                  :attribute_id, :saml_attribute_id

    rename_table :service_provider_attributes,
                 :service_provider_saml_attributes
  end
end
