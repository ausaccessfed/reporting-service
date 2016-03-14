class AddInstancesTimestampToAutomatedReports < ActiveRecord::Migration
  def change
    add_column :automated_reports,
               :instances_timestamp, :datetime
  end
end
