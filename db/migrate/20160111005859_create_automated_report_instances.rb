# frozen_string_literal: true

class CreateAutomatedReportInstances < ActiveRecord::Migration[4.2]
  def change
    create_table :automated_report_instances do |t|
      t.references :automated_report, null: false
      t.timestamp :range_start, null: false
      t.timestamps null: false

      t.foreign_key :automated_reports
    end
  end
end
