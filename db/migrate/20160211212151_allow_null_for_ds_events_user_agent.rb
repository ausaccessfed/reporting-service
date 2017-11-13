# frozen_string_literal: true

class AllowNullForDsEventsUserAgent < ActiveRecord::Migration[4.2]
  def change
    change_column :discovery_service_events, :user_agent, :string, null: true
  end
end
