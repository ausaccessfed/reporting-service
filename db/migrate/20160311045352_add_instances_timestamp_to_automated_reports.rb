# frozen_string_literal: true

class AddInstancesTimestampToAutomatedReports < ActiveRecord::Migration[4.2]
  def change
    add_column :automated_reports, :instances_timestamp, :datetime
  end
end
