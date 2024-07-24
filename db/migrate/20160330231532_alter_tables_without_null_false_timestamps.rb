# frozen_string_literal: true

class AlterTablesWithoutNullFalseTimestamps < ActiveRecord::Migration[4.2]
  TABLES = %w[subjects roles api_subjects permissions subject_roles api_subject_roles].freeze

  def change
    TABLES.each do |table|
      change_column_null(table.to_sym, :created_at, false)
      change_column_null(table.to_sym, :updated_at, false)
    end
  end
end
