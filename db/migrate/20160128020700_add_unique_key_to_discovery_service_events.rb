# frozen_string_literal: true

class AddUniqueKeyToDiscoveryServiceEvents < ActiveRecord::Migration
  def change
    add_index :discovery_service_events, %i[phase unique_id], unique: true
  end
end
