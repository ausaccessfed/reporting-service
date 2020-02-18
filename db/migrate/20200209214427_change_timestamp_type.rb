# frozen_string_literal: true

class ChangeTimestampType < ActiveRecord::Migration[4.2]
  def change
    change_column :federated_login_events, :timestamp, :datetime, null: false
    change_column :incoming_f_ticks_events, :timestamp, :datetime, null: false
    change_column :automated_report_instances, :range_end, :datetime, null: false
    change_column :activations, :activated_at, :datetime, null: false
    change_column :activations, :deactivated_at, :datetime, null: true
  end
end
