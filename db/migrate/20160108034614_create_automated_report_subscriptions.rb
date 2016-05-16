class CreateAutomatedReportSubscriptions < ActiveRecord::Migration
  def change
    create_table :automated_report_subscriptions do |t|
      t.references :automated_report, null: false
      t.references :subject, null: false
      t.string :identifier, null: false

      t.timestamps null: false

      t.index :identifier, unique: true
      t.foreign_key :automated_reports
      t.foreign_key :subjects
    end
  end
end
