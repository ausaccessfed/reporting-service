# frozen_string_literal: true

class AddOrganizationIdToServiceProviders < ActiveRecord::Migration[4.2]
  def change
    add_column :service_providers, :organization_id, :integer, null: false
    add_foreign_key :service_providers, :organizations
  end
end
