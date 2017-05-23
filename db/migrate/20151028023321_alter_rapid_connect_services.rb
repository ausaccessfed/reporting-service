# frozen_string_literal: true

class AlterRapidConnectServices < ActiveRecord::Migration
  def change
    rename_column :rapid_connect_services, :type, :service_type
  end
end
