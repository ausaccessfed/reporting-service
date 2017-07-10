# frozen_string_literal: true

class AddSourceToAutomatedReport < ActiveRecord::Migration[5.0]
  def change
    add_column :automated_reports, :source, :string
  end
end
