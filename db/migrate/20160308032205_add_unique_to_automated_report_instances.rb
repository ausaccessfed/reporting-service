class AddUniqueToAutomatedReportInstances < ActiveRecord::Migration
  def change
    add_index :automated_report_instances, [:range_start, :automated_report_id],
              name: 'automated_report_instances_start_report', unique: true
  end
end
