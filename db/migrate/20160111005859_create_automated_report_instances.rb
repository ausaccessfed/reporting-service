class CreateAutomatedReportInstances < ActiveRecord::Migration
  def change
    create_table :automated_report_instances do |t|
      t.references :automated_report, null: false
      t.timestamp :range_start, null: false
      t.timestamps
    end
  end
end
