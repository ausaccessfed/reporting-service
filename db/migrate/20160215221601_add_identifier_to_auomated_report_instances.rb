# frozen_string_literal: true

class AddIdentifierToAuomatedReportInstances < ActiveRecord::Migration
  def change
    add_column :automated_report_instances, :identifier, :string, null: false
    add_index :automated_report_instances, :identifier, unique: true
  end
end
