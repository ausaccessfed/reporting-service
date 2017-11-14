# frozen_string_literal: true

class RenameStartToEndInAutomatedSubscripitonInstances < ActiveRecord::Migration[4.2]
  def change
    rename_column :automated_report_instances, :range_start, :range_end
  end
end
