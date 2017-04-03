# frozen_string_literal: true

class RenameStartToEndInAutomatedSubscripitonInstances < ActiveRecord::Migration
  def change
    rename_column :automated_report_instances, :range_start, :range_end
  end
end
