class AddOrganizationIdToIdentityProviders < ActiveRecord::Migration
  def change
    add_column :identity_providers, :organization_id, :integer, null: false
    add_foreign_key :identity_providers, :organizations
  end
end
