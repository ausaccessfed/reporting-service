class AddIndexesForUtilizationReports < ActiveRecord::Migration
  def change
    add_index :discovery_service_events, [:unique_id, :phase], unique: true
    remove_index :discovery_service_events, column: [:phase, :unique_id],
                                            unique: true
    remove_index :discovery_service_events, column: :timestamp
    add_index :discovery_service_events, [:phase, :timestamp]
  end
end
