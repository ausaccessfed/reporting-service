# frozen_string_literal: true

class AddIndexesForUtilizationReports < ActiveRecord::Migration[4.2]
  def change
    add_index :discovery_service_events, %i[unique_id phase], unique: true
    remove_index :discovery_service_events, column: %i[phase unique_id], unique: true
    remove_index :discovery_service_events, column: :timestamp
    add_index :discovery_service_events, %i[phase timestamp]
  end
end
