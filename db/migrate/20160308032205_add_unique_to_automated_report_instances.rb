# frozen_string_literal: true

class AddUniqueToAutomatedReportInstances < ActiveRecord::Migration[4.2]
  def change
    add_index :automated_report_instances,
              %i[range_start automated_report_id],
              name: 'automated_report_instances_start_report',
              unique: true
  end
end
