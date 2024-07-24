# frozen_string_literal: true

class AllowLongerUserAgentStrings < ActiveRecord::Migration[4.2]
  def change
    change_column :discovery_service_events, :user_agent, :string, null: true, limit: 4096
  end
end
