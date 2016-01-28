class AddUniqueKeyToDiscoveryServiceEvents < ActiveRecord::Migration
  def change
    add_index :discovery_service_events, [:phase, :unique_id], unique: true
  end
end
