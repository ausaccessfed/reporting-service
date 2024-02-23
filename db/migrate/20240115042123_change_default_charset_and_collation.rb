# frozen_string_literal: true
class ChangeDefaultCharsetAndCollation < ActiveRecord::Migration[6.1]
  def up
    alter_encoding_all_tables('utf8mb4', 'utf8mb4_bin')
  end

  def down
    alter_encoding_all_tables('utf8', 'utf8_bin')
  end

  def alter_encoding_all_tables(character_set, collation)
    db = ActiveRecord::Base.connection

    execute "ALTER DATABASE `#{db.current_database}` CHARACTER SET #{character_set} COLLATE #{collation};"

    db.tables.each do |table|
      execute "ALTER TABLE `#{table}` CHARACTER SET #{character_set} COLLATE #{collation};"
      db
        .columns(table)
        .each do |column|
        default = column.default.nil? ? '' : "DEFAULT '#{column.default}'"
        null = column.null ? '' : 'NOT NULL'
        if column.sql_type =~ /([a-z]*)text/i || column.sql_type =~ /varchar\(([0-9]+)\)/i
          execute "ALTER TABLE `#{table}` MODIFY `#{column.name}` #{column.sql_type.upcase} CHARACTER SET #{character_set} COLLATE #{collation} #{default} #{null};"
        end
      end
    end
  end
end

