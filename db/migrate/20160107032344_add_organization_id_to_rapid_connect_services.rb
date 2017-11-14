# frozen_string_literal: true

class AddOrganizationIdToRapidConnectServices < ActiveRecord::Migration[4.2]
  def change
    add_column :rapid_connect_services, :organization_id, :integer, null: false
    add_foreign_key :rapid_connect_services, :organizations
  end
end
