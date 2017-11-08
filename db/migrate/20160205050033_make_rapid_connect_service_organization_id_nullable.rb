# frozen_string_literal: true

class MakeRapidConnectServiceOrganizationIdNullable < ActiveRecord::Migration[4.2]
  def change
    change_column :rapid_connect_services, :organization_id, :integer,
                  null: true, default: nil
  end
end
