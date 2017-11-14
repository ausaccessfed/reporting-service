# frozen_string_literal: true

class AddOrganizationIdToIdentityProviders < ActiveRecord::Migration[4.2]
  def change
    add_column :identity_providers, :organization_id, :integer, null: false
    add_foreign_key :identity_providers, :organizations
  end
end
