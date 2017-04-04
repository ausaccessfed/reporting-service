# frozen_string_literal: true

class AllowNullForDsEventsUserAgent < ActiveRecord::Migration
  def change
    change_column :discovery_service_events, :user_agent, :string, null: true
  end
end
