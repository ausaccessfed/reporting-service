# frozen_string_literal: true

class CreateAutomatedReports < ActiveRecord::Migration
  def change
    create_table :automated_reports do |t|
      t.string :report_class, null: false
      t.string :interval, null: false
      t.string :target, null: true

      t.timestamps null: false
    end
  end
end
